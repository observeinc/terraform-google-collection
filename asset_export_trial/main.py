# This snippet has been automatically generated and should be regarded as a
# code template only.
# It will require modifications to work:
# - It may require correct/in-range values for request initialization.
# - It may require specifying regional endpoints when creating the service
#   client as shown in:
#   https://googleapis.dev/python/google-api-core/latest/client_options.html
from google.cloud import asset_v1, storage
from google.oauth2 import service_account
import datetime
import sys

# CONTENT_TYPES = [
#     "CONTENT_TYPE_UNSPECIFIED",
#     "RESOURCE",
#     "IAM_POLICY",
#     "ORG_POLICY",
#     "ACCESS_POLICY",
#     "OS_INVENTORY",
#     "RELATIONSHIP",
# ]

CONTENT_TYPES = [
    # "CONTENT_TYPE_UNSPECIFIED",
    "RESOURCE",
    "IAM_POLICY",
    "ORG_POLICY",
    "ACCESS_POLICY"
]

# CONTENT_TYPES = [
#     "RESOURCE"
# ]


credentials = service_account.Credentials.from_service_account_file(
    "ephem-proj-collect-74a8714cd95e.json"
)

# Create a client
client = asset_v1.AssetServiceClient(credentials=credentials)

#PARENT = "projects/ephem-proj-collect"
PARENT = "folders/831845457119"
BUCKET_NAME = "manual-joe-asset-export"
BUCKET_PREFIX = f"gs://{BUCKET_NAME}/test"
FEED_NAME = "testy_feed"
FEED_ID = "testy_feed_id"
TOPIC_ID = "ephem-proj-coll-env"
COLLECTION_PROJECT = "ephem-proj-collect"
TOPIC_NAME = f"projects/{COLLECTION_PROJECT}/topics/{TOPIC_ID}"

ASSET_TYPES = ["aiplatform.googleapis.com.*", "anthos.googleapis.com.*", "apigateway.googleapis.com.*", "apikeys.googleapis.com.*", "appengine.googleapis.com.*", "apps.k8s.io.*", "artifactregistry.googleapis.com.*", "assuredworkloads.googleapis.com.*", "batch.k8s.io.*", "beyondcorp.googleapis.com.*", "bigquery.googleapis.com.*", "bigquerymigration.googleapis.com.*", "bigtableadmin.googleapis.com.*", "cloudbilling.googleapis.com.*", "clouddeploy.googleapis.com.*", "cloudfunctions.googleapis.com.*", "cloudkms.googleapis.com.*", "cloudresourcemanager.googleapis.com.*", "composer.googleapis.com.*", "compute.googleapis.com.*", "connectors.googleapis.com.*", "container.googleapis.com.*", "containerregistry.googleapis.com.*", "dataflow.googleapis.com.*", "dataform.googleapis.com.*", "datafusion.googleapis.com.*", "datamigration.googleapis.com.*", "dataplex.googleapis.com.*", "dataproc.googleapis.com.*", "datastream.googleapis.com.*", "dialogflow.googleapis.com.*", "dlp.googleapis.com.*", "dns.googleapis.com.*", "documentai.googleapis.com.*", "domains.googleapis.com.*", "eventarc.googleapis.com.*", "extensions.k8s.io.*", "file.googleapis.com.*", "firestore.googleapis.com.*", "gameservices.googleapis.com.*", "gkebackup.googleapis.com.*", "gkehub.googleapis.com.*", "healthcare.googleapis.com.*", "iam.googleapis.com.*", "ids.googleapis.com.*", "k8s.io.*", "logging.googleapis.com.*", "managedidentities.googleapis.com.*", "memcache.googleapis.com.*", "metastore.googleapis.com.*", "monitoring.googleapis.com.*", "networkconnectivity.googleapis.com.*", "networking.k8s.io.*", "networkmanagement.googleapis.com.*", "networkservices.googleapis.com.*", "orgpolicy.googleapis.com.*", "osconfig.googleapis.com.*", "privateca.googleapis.com.*", "pubsub.googleapis.com.*", "rbac.authorization.k8s.io.*", "redis.googleapis.com.*", "run.googleapis.com.*", "secretmanager.googleapis.com.*", "servicedirectory.googleapis.com.*", "servicemanagement.googleapis.com.*", "serviceusage.googleapis.com.*", "spanner.googleapis.com.*", "speech.googleapis.com.*", "sqladmin.googleapis.com.*", "storage.googleapis.com.*", "tpu.googleapis.com.*", "transcoder.googleapis.com.*", "vpcaccess.googleapis.com.*", "workflows.googleapis.com.*"]
#ASSET_TYPES = ["storage.googleapis.com.*"]

def sample_export_assets():
    # Initialize request argument(s)
    output_config = asset_v1.OutputConfig()

    # This can be everything in one file or broken down by asset type
    # output_config.gcs_destination.uri = "gs://manual-arthur-asset-export/moassets"
    #output_config.gcs_destination.uri_prefix = BUCKET_PREFIX

    for CONTENT_TYPE in CONTENT_TYPES:
        now = datetime.datetime.now()
        timestamp_str = now.strftime("%Y%m%d_%H%M%S")
        output_config.gcs_destination.uri_prefix = f"gs://{BUCKET_NAME}/asset_export_{timestamp_str}"
        request = asset_v1.ExportAssetsRequest(
            parent = PARENT,
            output_config = output_config,
            content_type = CONTENT_TYPE,
            # asset_types="storage.googleapis.com/Bucket",
        )
        # Make the request
        operation = client.export_assets(request=request)
        
        print("Waiting for operation to complete...")

        response = operation.result()

        # Handle the response
        print(CONTENT_TYPE)
        print(response)


# This snippet has been automatically generated and should be regarded as a
# code template only.
# It will require modifications to work:
# - It may require correct/in-range values for request initialization.
# - It may require specifying regional endpoints when creating the service
#   client as shown in:
#   https://googleapis.dev/python/google-api-core/latest/client_options.html
# from google.cloud import asset_v1


def sample_create_feed():
    # Create a client
    client = asset_v1.AssetServiceClient(credentials=credentials)
    # Initialize request argument(s)
    feed = asset_v1.Feed()
    # This needs to be variable
    feed.name = FEED_NAME
    feed.feed_output_config.pubsub_destination.topic = TOPIC_NAME
    # We need to create a feed for each content type
    for CONTENT_TYPE in CONTENT_TYPES:
        try:
            feed.content_type = CONTENT_TYPE
            # We need to pull a list from bucket of the asset types
            # https://cloud.google.com/asset-inventory/docs/supported-asset-types
            feed.asset_types = ASSET_TYPES
            request = asset_v1.CreateFeedRequest(
                parent=PARENT,
                feed_id=f"{FEED_ID}-{CONTENT_TYPE}",
                feed=feed,
            )
            # Make the request
            response = client.create_feed(request=request)

            # Handle the response
            print(response)
        except Exception as err:
            print(f"Content Type={CONTENT_TYPE}")
            print(f"Unexpected {err=}, {type(err)=}")



# https://github.com/googleapis/python-storage/blob/main/samples/snippets/storage_list_files.py
# python-storage/samples/snippets/storage_download_to_stream.py
# https://github.com/googleapis/python-pubsub/
# https://github.com/googleapis/python-storage/blob/main/samples/snippets/storage_delete_file.py


def list_blobs():
    """Lists all the blobs in the bucket."""
    bucket_name = BUCKET_NAME

    storage_client = storage.Client()

    # Note: Client.list_blobs requires at least package version 1.17.0.
    blobs = storage_client.list_blobs(bucket_name)

    # Note: The call returns a response only when the iterator is consumed.
    for blob in blobs:
        if not blob.name.endswith("/"):
            download_blob_into_memory(bucket_name, blob.name)
            # break
            #print(blob.name)


def delete_blob(bucket_name, blob_name):
    """Deletes a blob from the bucket."""
    # bucket_name = "your-bucket-name"f
    # blob_name = "your-object-name"

    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)
    generation_match_precondition = None

    # Optional: set a generation-match precondition to avoid potential race conditions
    # and data corruptions. The request to delete is aborted if the object's
    # generation number does not match your precondition.
    blob.reload()  # Fetch blob metadata to use in generation_match_precondition.
    generation_match_precondition = blob.generation

    blob.delete(if_generation_match=generation_match_precondition)

    print(f"Blob {blob_name} deleted.")

def download_blob_into_memory(bucket_name, blob_name):
    """Downloads a blob into memory."""
    # The ID of your GCS bucket
    # bucket_name = "your-bucket-name"

    # The ID of your GCS object
    # blob_name = "storage-object-name"

    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name)

    # Construct a client side representation of a blob.
    # Note `Bucket.blob` differs from `Bucket.get_blob` as it doesn't retrieve
    # any content from Google Cloud Storage. As we don't need additional data,
    # using `Bucket.blob` is preferred here.
    blob = bucket.blob(blob_name)
    #contents = blob.download_as_string()
    contents = blob.download_as_bytes()
    publish_messages_with_custom_attributes(contents)
    delete_blob(BUCKET_NAME, blob_name)

    # print(
    #     "Downloaded storage object {} from bucket {} as the following string: {}.".format(
    #         blob_name, bucket_name, contents
    #     )
    # )


def publish_messages_with_custom_attributes(byte_str: bytes) -> None:
    """Publishes multiple messages with custom attributes
    to a Pub/Sub topic."""
    # [START pubsub_publish_custom_attributes]
    from google.cloud import pubsub_v1

    # TODO(developer)
    project_id = COLLECTION_PROJECT
    topic_id = TOPIC_ID

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    for line in byte_str.splitlines():
        # data_str = f"Message number {n}"
        # Data must be a bytestring
        # data = line.encode("utf-8")
        # Add two attributes, origin and username, to the message
        future = publisher.publish(
            topic_path, data=line, origin="python-sample", username="gcp", observe_gcp_kind="https://cloud.google.com/asset-inventory/docs/reference/rest/v1/TopLevel/exportAssets")
        print(future.result())

    print(f"Published messages with custom attributes to {topic_path}.")
    
    # [END pubsub_publish_custom_attributes]

def list_feeds():
    client = asset_v1.AssetServiceClient()
    response = client.list_feeds(request={"parent": PARENT})
    print(f"feeds: {response.feeds}")

def delete_feeds():
    client = asset_v1.AssetServiceClient()
    response = client.list_feeds(request={"parent": PARENT})
    for feeds in response.feeds:
        client.delete_feed(request={"name": feeds.name})
    print(f"Deleted: {feeds.name}" )