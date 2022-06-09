package cloudfunctions

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	asset "cloud.google.com/go/asset/apiv1"
	"cloud.google.com/go/functions/metadata"
	"cloud.google.com/go/pubsub"
	"cloud.google.com/go/storage"
	assetpb "google.golang.org/genproto/googleapis/cloud/asset/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var (
	name      string
	bucket    string
	projectID string
	topicID   string

	assetTypes   []string
	contentTypes []assetpb.ContentType
)

func init() {
	getEnvVars()
}

func getEnvVars() {
	name = os.Getenv("NAME")
	bucket = os.Getenv("BUCKET")
	projectID = os.Getenv("PROJECT_ID")
	topicID = os.Getenv("TOPIC_ID")
	assetTypeStr := os.Getenv("ASSET_TYPES")
	contentTypeStr := os.Getenv("CONTENT_TYPES")

	var err error
	if assetTypeStr != "" {
		err = json.Unmarshal([]byte(assetTypeStr), &assetTypes)
		if err != nil {
			panic(err)
		}
	}

	if contentTypeStr != "" {
		var contentTypeNames []string
		err = json.Unmarshal([]byte(contentTypeStr), &contentTypeNames)
		if err != nil {
			panic(err)
		}

		for _, name := range contentTypeNames {
			v, ok := assetpb.ContentType_value[name]
			if !ok {
				panic(fmt.Sprintf("unknown content type: %s", name))
			}
			if v == int32(assetpb.ContentType_RELATIONSHIP) {
				// We cannot import relationships until the following issue is resolved: https://issuetracker.google.com/issues/209387751
				// assetpb.ContentType_RELATIONSHIP,
				panic("exports for content type relationship are unsupported:  https://issuetracker.google.com/issues/209387751")
			}
			contentTypes = append(contentTypes, assetpb.ContentType(v))
		}
	}
}

func buildObjectName(bucket string, contentType assetpb.ContentType, snapshotTime time.Time) string {
	return "gs://" + bucket + "/" + assetpb.ContentType_name[int32(contentType)] + "/" + strconv.FormatInt(snapshotTime.UnixNano(), 10)
}

func parseObjectName(name string) (string, string, time.Time, error) {
	parts := strings.Split(name, "/")

	log.Printf("name split parts length = %d", len(parts))

	if len(parts) != 3 && len(parts) != 2 {
		return "", "", time.Time{}, fmt.Errorf("expected 2 or 3 parts after splitting (name=%s)", name)
	}

	var uriPrefix string
	var contentType string
	var timeStr string

	if len(parts) == 3 {
		uriPrefix = parts[0]
		contentType = parts[1]
		timeStr = parts[2]
	}

	if len(parts) == 2 {
		contentType = parts[0]
		timeStr = parts[1]
	}

	timeInt, err := strconv.ParseInt(timeStr, 10, 64)
	if err != nil {
		return "", "", time.Time{}, fmt.Errorf("strconv.ParseInt: %w", err)
	}
	return uriPrefix, contentType, time.Unix(0, timeInt), nil
}

// StartExport is a Cloud Function HTTP endpoint that initializes multiple Cloud Asset export jobs.
// One export job is created per type in "contentTypes" and assets are exported to the Cloud Storage bucket with name "bucket".
func StartExport(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	client, err := asset.NewClient(ctx)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf("asset.NewClient: %s", err)))
	}
	defer client.Close()

	for _, contentType := range contentTypes {
		// Set snapshotTime to 1 minute ago because of the following issue with ExportAssets:
		// "Due to delays in resource data collection and indexing, there is a volatile window during which running the same query may get different results."
		snapshotTime := time.Now().Add(-time.Minute)
		uri := buildObjectName(bucket, contentType, snapshotTime)
		log.Printf("starting export with destination %s", uri)

		_, err = client.ExportAssets(ctx, &assetpb.ExportAssetsRequest{
			Parent:      fmt.Sprintf("projects/%s", projectID),
			AssetTypes:  assetTypes,
			ContentType: contentType,
			ReadTime:    timestamppb.New(snapshotTime),
			OutputConfig: &assetpb.OutputConfig{
				Destination: &assetpb.OutputConfig_GcsDestination{
					GcsDestination: &assetpb.GcsDestination{
						ObjectUri: &assetpb.GcsDestination_Uri{
							Uri: uri,
						},
					},
				},
			},
		})

		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(fmt.Sprintf("client.ExportAssets: %s", err)))
		}
	}
}

type GCSEvent struct {
	Kind   string `json:"kind"`
	Name   string `json:"name"`
	Bucket string `json:"bucket"`
}

// ProcessExport is an event-trigger Cloud Function entrypoint. It responds to
// the Google Cloud Storage "object.finalize" event by reading the newline-delimited JSON
// in the Cloud Storage Object and writing it to the Pub/Sub topic with id "topicID".
//
// ProcessExport can be called multiple times for a single object, so duplicate events may
// be written into the Pub/Sub topic.
//
// Lines longer than 65536 bytes are automatically split into separate pubsub events.
func ProcessExport(ctx context.Context, e GCSEvent) error {
	storageClient, err := storage.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("storage.NewClient: %w", err)
	}
	defer storageClient.Close()

	pubsubClient, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return fmt.Errorf("pubsub.NewClient: %w", err)
	}
	defer pubsubClient.Close()

	bkt := storageClient.Bucket(e.Bucket)
	obj := bkt.Object(e.Name)

	log.Printf("processing file %s", e.Name)
	log.Printf("Bucket Name %s", e.Bucket)

	_, _, snapshotTime, err := parseObjectName(e.Name)

	if err != nil {
		return fmt.Errorf("parseObjectName: %w", err)
	}

	r, err := obj.NewReader(ctx)
	if err != nil {
		return fmt.Errorf("obj.NewReader: %w", err)
	}

	topic := pubsubClient.Topic(topicID)
	defer topic.Stop()

	numLines := 0
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		line := scanner.Text()
		numLines++

		_ = topic.Publish(ctx, &pubsub.Message{
			Data: []byte(line),
			Attributes: map[string]string{
				"snapshotTime": strconv.FormatInt(snapshotTime.UnixNano(), 10),
			},
		})
	}
	log.Printf("published %d messages asynchronously", numLines)
	topic.Flush()

	return nil
}

// ManageFeeds is a Cloud Function event-trigger entrypoint.
// It responds to the GCS event by either creating or deleting multiple Cloud Asset Feeds.
//
// ManageFeeds will create exactly feeds for each object in the Cloud Storage bucket. For
// each object, there will be exactly len(contentTypes) feeds created, one per feed.
//
// ManageFeeds will fail to delete feeds if the "NAME" or "contentTypes" env variables are changed.
// The feeds should be deleted before these env variables are changed.
func ManageFeeds(ctx context.Context, e GCSEvent) error {
	meta, err := metadata.FromContext(ctx)
	if err != nil {
		return fmt.Errorf("metadata.FromContext: %v", err)
	}

	client, err := asset.NewClient(ctx)
	if err != nil {
		return fmt.Errorf("asset.NewClient: %w", err)
	}

	feedIDFunc := func(objectName string, contentType assetpb.ContentType) string {
		return name + "-" + objectName + "-" + strconv.FormatInt(int64(contentType), 10)
	}

	if meta.EventType == "google.storage.object.finalize" {
		log.Printf("creating %d feeds", len(contentTypes))
		for _, contentType := range contentTypes {
			id := feedIDFunc(e.Name, contentType)
			log.Printf("creating feed %s of type %s", id, assetpb.ContentType_name[int32(contentType)])
			_, err = client.CreateFeed(ctx, &assetpb.CreateFeedRequest{
				Parent: fmt.Sprintf("projects/%s", projectID),
				FeedId: id,
				Feed: &assetpb.Feed{
					AssetTypes:  assetTypes,
					ContentType: contentType,
					FeedOutputConfig: &assetpb.FeedOutputConfig{
						Destination: &assetpb.FeedOutputConfig_PubsubDestination{
							PubsubDestination: &assetpb.PubsubDestination{
								Topic: fmt.Sprintf("projects/%s/topics/%s", projectID, topicID),
							},
						},
					},
				},
			})

			if err != nil {
				return fmt.Errorf("client.CreateFeed: %w", err)
			}
		}
	} else if meta.EventType == "google.storage.object.delete" {
		log.Printf("deleting up to %d feeds", len(contentTypes))
		res, err := client.ListFeeds(ctx, &assetpb.ListFeedsRequest{Parent: fmt.Sprintf("projects/%s", projectID)})
		if err != nil {
			return fmt.Errorf("client.ListFeeds: %w", err)
		}
		feedNames := make(map[string]string, len(res.Feeds))
		for _, feed := range res.Feeds {
			parts := strings.Split(feed.Name, "/")
			id := parts[len(parts)-1]
			feedNames[id] = feed.Name
		}

		for _, contentType := range contentTypes {
			id := feedIDFunc(e.Name, contentType)
			if feedName, ok := feedNames[id]; ok {
				log.Printf("found and deleting feed %s of type %s", feedName, assetpb.ContentType_name[int32(contentType)])
				err = client.DeleteFeed(ctx, &assetpb.DeleteFeedRequest{Name: feedName})
				if err != nil {
					return fmt.Errorf("client.DeleteFeed: %w", err)
				}
			}
		}
	}
	return nil
}
