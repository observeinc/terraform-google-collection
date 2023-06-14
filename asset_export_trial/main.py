# This snippet has been automatically generated and should be regarded as a
# code template only.
# It will require modifications to work:
# - It may require correct/in-range values for request initialization.
# - It may require specifying regional endpoints when creating the service
#   client as shown in:
#   https://googleapis.dev/python/google-api-core/latest/client_options.html
from google.cloud import asset_v1, storage
from google.oauth2 import service_account
import sys


credentials = service_account.Credentials.from_service_account_file(
    "content-eng-sample-infra-9c53c49cd856.json"
)

# Create a client
client = asset_v1.AssetServiceClient(credentials=credentials)


def sample_export_assets():
    # Initialize request argument(s)
    output_config = asset_v1.OutputConfig()

    # This can be everything in one file or broken down by asset type
    # output_config.gcs_destination.uri = "gs://manual-arthur-asset-export/moassets"
    output_config.gcs_destination.uri_prefix = (
        "gs://manual-arthur-asset-export/breakdown"
    )

    request = asset_v1.ExportAssetsRequest(
        parent="projects/content-eng-sample-infra",
        output_config=output_config,
        content_type="RESOURCE",
        # asset_types="storage.googleapis.com/Bucket",
    )

    # Make the request
    operation = client.export_assets(request=request)

    print("Waiting for operation to complete...")

    response = operation.result()

    # Handle the response
    print(response)


# This snippet has been automatically generated and should be regarded as a
# code template only.
# It will require modifications to work:
# - It may require correct/in-range values for request initialization.
# - It may require specifying regional endpoints when creating the service
#   client as shown in:
#   https://googleapis.dev/python/google-api-core/latest/client_options.html
from google.cloud import asset_v1


def sample_create_feed():
    # Create a client
    client = asset_v1.AssetServiceClient(credentials=credentials)

    # Initialize request argument(s)
    feed = asset_v1.Feed()
    feed.name = "name_value"
    feed.content_type = "RESOURCE"
    feed.asset_types = ["storage.googleapis.com.*", "compute.googleapis.com.*"]
    feed.feed_output_config.pubsub_destination.topic = (
        "projects/content-eng-sample-infra/topics/infra-coll-env"
    )

    request = asset_v1.CreateFeedRequest(
        parent="projects/content-eng-sample-infra",
        feed_id="my_arbitrary_string",
        feed=feed,
    )

    # Make the request
    response = client.create_feed(request=request)

    # Handle the response
    print(response)


# https://github.com/googleapis/python-storage/blob/main/samples/snippets/storage_list_files.py
# python-storage/samples/snippets/storage_download_to_stream.py
# https://github.com/googleapis/python-pubsub/
# https://github.com/googleapis/python-storage/blob/main/samples/snippets/storage_delete_file.py


def list_blobs():
    """Lists all the blobs in the bucket."""
    bucket_name = "manual-arthur-asset-export"

    storage_client = storage.Client()

    # Note: Client.list_blobs requires at least package version 1.17.0.
    blobs = storage_client.list_blobs(bucket_name)

    # Note: The call returns a response only when the iterator is consumed.
    for blob in blobs:
        if not blob.name.endswith("/"):
            download_blob_into_memory(bucket_name, blob.name)
            break
            # print(blob.name)


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
    # contents = blob.download_as_string()
    contents = blob.download_as_bytes()
    publish_messages_with_custom_attributes(contents)

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
    project_id = "content-eng-sample-infra"
    topic_id = "infra-coll-env"

    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    for line in byte_str.splitlines():
        # data_str = f"Message number {n}"
        # Data must be a bytestring
        # data = line.encode("utf-8")
        # Add two attributes, origin and username, to the message
        future = publisher.publish(
            topic_path, line, origin="python-sample", username="gcp"
        )
        print(future.result())

    print(f"Published messages with custom attributes to {topic_path}.")
    # [END pubsub_publish_custom_attributes]
