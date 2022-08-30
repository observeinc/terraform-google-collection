package cloudfunctions

import (
	"context"
	"encoding/json"
	"errors"
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
	"google.golang.org/api/cloudresourcemanager/v1"
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

func ProjectExport(w http.ResponseWriter, r *http.Request) {
	// https://pkg.go.dev/google.golang.org/api@v0.86.0/cloudresourcemanager/v1#ListProjectsResponse
	ctx := r.Context()
	cloudresourcemanagerService, err := cloudresourcemanager.NewService(ctx)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf("cloudresourcemanager.NewService: %s", err)))
		return
	}

	projects := cloudresourcemanagerService.Projects.List()

	doNextPageToken := "RunAtLeastOnce"

	for doNextPageToken != "" {
		result := &cloudresourcemanager.ListProjectsResponse{}
		err := *new(error)

		if doNextPageToken == "RunAtLeastOnce" {
			result, err = projects.Do()
		} else {
			projects.PageToken(doNextPageToken)
			result, err = projects.Do()
		}

		if err != nil {
			print(err)
		}

		publishProjects(result, ctx, w)

		doNextPageToken = result.NextPageToken

		if doNextPageToken == "" {
			fmt.Println("Next Page is Empty")
		}

	}
}

func publishProjects(projResponse *cloudresourcemanager.ListProjectsResponse, ctx context.Context, w http.ResponseWriter) {
	// https://pkg.go.dev/google.golang.org/api@v0.86.0/cloudresourcemanager/v1#Project
	// tough, err := json.Marshal(result.Projects)

	pubsubClient, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf("pubsub.NewClient: %s", err)))
		return
	}
	defer pubsubClient.Close()

	topic := pubsubClient.Topic(topicID)
	defer topic.Stop()
	numMessages := 0
	var results []*pubsub.PublishResult
	for _, project := range projResponse.Projects {
		snapshotTime := time.Now().Add(-time.Minute)

		projLine, _ := project.MarshalJSON()
		fmt.Println(string(projLine))

		collecting := "false"
		if projectID == project.ProjectId {
			collecting = "true"
		}

		pubResult := topic.Publish(ctx, &pubsub.Message{
			Data: []byte(projLine),
			Attributes: map[string]string{
				"snapshotTime": strconv.FormatInt(snapshotTime.UnixNano(), 10),
				"data_type":    "cloudresourcemanager.Project",
				"collecting":   collecting,
			},
		})

		results = append(results, pubResult)

		numMessages++
	}

	for _, r := range results {
		id, err := r.Get(ctx)
		if err != nil {
			fmt.Printf("Publisherror: %s\n", err)
		}
		fmt.Printf("Published a message with a message ID: %s\n", id)
	}

	log.Printf("published %d messages asynchronously", numMessages)
}

// Test Project Exports locally
// Create directory localgotest at root of repo
// in test run go mod init example.com/test

// place code below in main.go in test dir

// run folowing commands
// go mod edit -replace github.com/observeinc/cloudfunctions=../cloudfunctions

// go mod tidy
// should see response like this -  go: found github.com/observeinc/cloudfunctions in github.com/observeinc/cloudfunctions v0.0.0-00010101000000-000000000000

// run command setting env variables - export NAME=arthur; export PROJECT_ID=terraflood-345116; export TOPIC_ID=arthur; go run .

//place this in main.go

// package main

// import (
// 	"net/http/httptest"

// 	"context"

// 	"net/http"

// 	"github.com/observeinc/cloudfunctions"
// )

// func main() {
// 	w := httptest.NewRecorder()
// 	r := httptest.NewRequest(http.MethodGet, "/", nil)
// 	r.WithContext(context.Background())
// 	cloudfunctions.ProjectExport(w, r)
// }
