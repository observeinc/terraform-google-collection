
# Create a feed that sends notifications about network resource updates.
resource "google_cloud_asset_project_feed" "project_feed" {
  #project          = "projects/${var.project_id}"
  project          = var.project_id
  #feed_id          = "projects/${data.google_project.project.number}/feeds/${var.feed_name}"
  feed_id          = var.feed_name
  content_type     = "RESOURCE"

  asset_types = ["aiplatform.googleapis.com.*", "anthos.googleapis.com.*", "apigateway.googleapis.com.*", "apikeys.googleapis.com.*", "appengine.googleapis.com.*", "apps.k8s.io.*", "artifactregistry.googleapis.com.*", "assuredworkloads.googleapis.com.*", "batch.k8s.io.*", "beyondcorp.googleapis.com.*", "bigquery.googleapis.com.*", "bigquerymigration.googleapis.com.*", "bigtableadmin.googleapis.com.*", "cloudbilling.googleapis.com.*", "clouddeploy.googleapis.com.*", "cloudfunctions.googleapis.com.*", "cloudkms.googleapis.com.*", "cloudresourcemanager.googleapis.com.*", "composer.googleapis.com.*", "compute.googleapis.com.*", "connectors.googleapis.com.*", "container.googleapis.com.*", "containerregistry.googleapis.com.*", "dataflow.googleapis.com.*", "dataform.googleapis.com.*", "datafusion.googleapis.com.*", "datamigration.googleapis.com.*", "dataplex.googleapis.com.*", "dataproc.googleapis.com.*", "datastream.googleapis.com.*", "dialogflow.googleapis.com.*", "dlp.googleapis.com.*", "dns.googleapis.com.*", "documentai.googleapis.com.*", "domains.googleapis.com.*", "eventarc.googleapis.com.*", "extensions.k8s.io.*", "file.googleapis.com.*", "firestore.googleapis.com.*", "gameservices.googleapis.com.*", "gkebackup.googleapis.com.*", "gkehub.googleapis.com.*", "healthcare.googleapis.com.*", "iam.googleapis.com.*", "ids.googleapis.com.*", "k8s.io.*", "logging.googleapis.com.*", "managedidentities.googleapis.com.*", "memcache.googleapis.com.*", "metastore.googleapis.com.*", "monitoring.googleapis.com.*", "networkconnectivity.googleapis.com.*", "networking.k8s.io.*", "networkmanagement.googleapis.com.*", "networkservices.googleapis.com.*", "orgpolicy.googleapis.com.*", "osconfig.googleapis.com.*", "privateca.googleapis.com.*", "pubsub.googleapis.com.*", "rbac.authorization.k8s.io.*", "redis.googleapis.com.*", "run.googleapis.com.*", "secretmanager.googleapis.com.*", "servicedirectory.googleapis.com.*", "servicemanagement.googleapis.com.*", "serviceusage.googleapis.com.*", "spanner.googleapis.com.*", "speech.googleapis.com.*", "sqladmin.googleapis.com.*", "storage.googleapis.com.*", "tpu.googleapis.com.*", "transcoder.googleapis.com.*", "vpcaccess.googleapis.com.*", "workflows.googleapis.com.*"]

  feed_output_config {
    pubsub_destination {
      topic = var.topic_id
    }
  }

  # condition {
  #   expression = <<-EOT
  #   !temporal_asset.deleted &&
  #   temporal_asset.prior_asset_state == google.cloud.asset.v1.TemporalAsset.PriorAssetState.DOES_NOT_EXIST
  #   EOT
  #   title = "created"
  #   description = "Send notifications on creation events"
  # }
}

# The topic where the resource change notifications will be sent.
# resource "google_pubsub_topic" "feed_output" {
#   project  = "joe-test-proj"
#   name     = "observe"
# }

# Find the project number of the project whose identity will be used for sending
# the asset change notifications.
data "google_project" "project" {
  project_id = var.project_id
}