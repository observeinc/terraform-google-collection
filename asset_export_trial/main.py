# This snippet has been automatically generated and should be regarded as a
# code template only.
# It will require modifications to work:
# - It may require correct/in-range values for request initialization.
# - It may require specifying regional endpoints when creating the service
#   client as shown in:
#   https://googleapis.dev/python/google-api-core/latest/client_options.html
from google.cloud import asset_v1
from google.oauth2 import service_account

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
