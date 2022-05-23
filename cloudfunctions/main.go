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
	"cloud.google.com/go/pubsub"
	"cloud.google.com/go/storage"
	assetpb "google.golang.org/genproto/googleapis/cloud/asset/v1"
	"google.golang.org/protobuf/types/known/timestamppb"
)

var (
	uriPrefix = "gs://" + os.Getenv("BUCKET") + "/"
	projectID = os.Getenv("PROJECT_ID")
	topicId   = os.Getenv("TOPIC_ID")

	assetTypes   []string
	contentTypes []assetpb.ContentType
)

func init() {
	initAssetVars()
}

func initAssetVars() {
	assetTypeStr := os.Getenv("ASSET_TYPES")
	contentTypeStr := os.Getenv("CONTENT_TYPES")

	var err error
	err = json.Unmarshal([]byte(assetTypeStr), &assetTypes)
	if err != nil {
		panic(err)
	}

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

func buildObjectName(uriPrefix string, contentType assetpb.ContentType, snapshotTime time.Time) string {
	return uriPrefix + "-" + assetpb.ContentType_name[int32(contentType)] + "-" + strconv.FormatInt(snapshotTime.UnixNano(), 10)
}

func parseObjectName(name string) (string, string, time.Time, error) {
	parts := strings.Split(name, "-")
	if len(parts) != 3 {
		return "", "", time.Time{}, fmt.Errorf("expected 3 parts after splitting (name=%s)", name)
	}

	uriPrefix := parts[0]
	contentType := parts[1]
	timeStr := parts[2]
	timeInt, err := strconv.ParseInt(timeStr, 10, 64)
	if err != nil {
		return "", "", time.Time{}, fmt.Errorf("strconv.ParseInt: %w", err)
	}
	return uriPrefix, contentType, time.Unix(0, timeInt), nil
}

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
		uri := buildObjectName(uriPrefix, contentType, snapshotTime)
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
							Uri: buildObjectName(uriPrefix, contentType, snapshotTime),
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
	Name   string `json:"name"`
	Bucket string `json:"bucket"`
}

// ProcessExport takes the newline-delimited JSON in the export and writes it to Pub/Sub
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

	_, _, snapshotTime, err := parseObjectName(e.Name)
	if err != nil {
		return fmt.Errorf("parseObjectName: %w", err)
	}

	r, err := obj.NewReader(ctx)
	if err != nil {
		return fmt.Errorf("obj.NewReader: %w", err)
	}

	topic := pubsubClient.Topic(topicId)
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
