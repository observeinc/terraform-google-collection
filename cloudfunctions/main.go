package cloudfunctions

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	asset "cloud.google.com/go/asset/apiv1"
	"cloud.google.com/go/functions/metadata"
	assetpb "google.golang.org/genproto/googleapis/cloud/asset/v1"
)

var (
	name      string
	projectID string
	topicID   string

	assetTypes   []string
	contentTypes []assetpb.ContentType
)

func init() {
	err := getEnvVars()
	if err != nil {
		panic(fmt.Sprintf("getEnvVars: %s", err))
	}
}

func getEnvVars() error {
	name = os.Getenv("NAME")
	projectID = os.Getenv("PROJECT_ID")
	topicID = os.Getenv("TOPIC_ID")
	assetTypeStr := os.Getenv("ASSET_TYPES")
	contentTypeStr := os.Getenv("CONTENT_TYPES")

	var err error
	if assetTypeStr != "" {
		err = json.Unmarshal([]byte(assetTypeStr), &assetTypes)
		if err != nil {
			return err
		}
	}

	if contentTypeStr != "" {
		var contentTypeNames []string
		err = json.Unmarshal([]byte(contentTypeStr), &contentTypeNames)
		if err != nil {
			return err
		}

		for _, name := range contentTypeNames {
			v, ok := assetpb.ContentType_value[name]
			if !ok {
				return fmt.Errorf("unknown content type: %s", name)
			}
			if v == int32(assetpb.ContentType_RELATIONSHIP) {
				// We cannot import relationships until the following issue is resolved: https://issuetracker.google.com/issues/209387751
				// assetpb.ContentType_RELATIONSHIP,
				return errors.New("exports for content type relationship are unsupported:  https://issuetracker.google.com/issues/209387751")
			}
			contentTypes = append(contentTypes, assetpb.ContentType(v))
		}
	}
	return nil
}

type GCSEvent struct {
	Kind   string `json:"kind"`
	Name   string `json:"name"`
	Bucket string `json:"bucket"`
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
