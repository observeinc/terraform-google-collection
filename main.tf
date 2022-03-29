locals {
  pubsub_url_path = base64encode("${var.observe_customer}:${var.observe_token}")
}

data "google_project" "current" {
}

resource "google_project_service" "storage" {
  service                    = "storage.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "pubsub" {
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "asset_inventory" {
  service                    = "cloudasset.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "logging" {
  service                    = "logging.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "monitoring" {
  service                    = "monitoring.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "functions" {
  service                    = "cloudfunctions.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "scheduler" {
  service                    = "cloudscheduler.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_storage_bucket" "asset_inventory_export_snapshots" {
  name          = "${var.prefix}-asset-inventory-snapshots"
  force_destroy = true
  location      = var.region
}

resource "google_pubsub_topic" "the_topic" {
  name = var.prefix

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }
}

resource "google_pubsub_subscription" "the_subscription" {
  name  = var.prefix
  topic = google_pubsub_topic.the_topic.name

  push_config {
    push_endpoint = "https://pubsub.collect.${var.observe_domain}.com/${local.pubsub_url_path}"
  }
  ack_deadline_seconds       = 60
  message_retention_duration = "86400s" // 24 hours
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}

resource "google_cloud_asset_project_feed" "the_feed" {
  feed_id      = var.prefix
  asset_types  = [".*"]
  content_type = "RESOURCE"

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.the_topic.id
    }
  }
}

resource "google_logging_project_sink" "the_sink" {
  name                   = var.prefix
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.the_topic.id}"
  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_member" "the_sink_pubsub" {
  project = google_pubsub_topic.the_topic.project
  topic   = google_pubsub_topic.the_topic.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.the_sink.writer_identity
}

resource "google_service_account" "cloud_functions" {
  account_id  = "${substr(var.prefix, 0, 16)}-function-sa" // Name can't be longer than 28 characters
  description = "A service account for the Observe Collection Cloud Functions"
}

resource "google_project_iam_member" "cloud_functions_cloud_asset" {
  project = data.google_project.current.project_id
  role    = "roles/cloudasset.viewer"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_project_iam_member" "cloud_functions_cloud_storage" {
  project = data.google_project.current.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_project_iam_member" "cloud_functions_pub_sub" {
  project = data.google_project.current.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_cloudfunctions_function" "start_export" {
  name   = "${var.prefix}-start-export"
  region = var.region

  description = "Trigger a Cloud Asset export to Cloud Storage"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "StartExport"
  source_archive_bucket = "prototype-luke-asset-inventory"
  source_archive_object = "cloudfunctions.zip"

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" // Needed so that Cloud Scheduler can trigger the Cloud Function

  environment_variables = {
    "BUCKET"     = google_storage_bucket.asset_inventory_export_snapshots.name
    "PROJECT_ID" = data.google_project.current.project_id
    "TOPIC_ID"   = google_pubsub_topic.the_topic.name
  }

  max_instances = 5
}

resource "google_cloudfunctions_function" "process_export" {
  name   = "${var.prefix}-process-export"
  region = var.region

  description = "Write the contents of a Cloud Asset export to Pub/Sub"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "ProcessExport"
  source_archive_bucket = "prototype-luke-asset-inventory"
  source_archive_object = "cloudfunctions.zip"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.asset_inventory_export_snapshots.name
  }

  environment_variables = {
    "BUCKET"     = google_storage_bucket.asset_inventory_export_snapshots.name
    "PROJECT_ID" = data.google_project.current.project_id
    "TOPIC_ID"   = google_pubsub_topic.the_topic.name
  }

  max_instances = 5
}

resource "google_service_account" "cloud_scheduler" {
  account_id = "${substr(var.prefix, 0, 15)}-scheduler-sa" // Name can't be longer than 28 characters
}

resource "google_project_iam_member" "cloud_scheduler_cloud_function_invoker" {
  project = data.google_project.current.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloud_scheduler.email}"
}

resource "google_cloud_scheduler_job" "trigger_start_export" {
  name        = var.prefix
  description = "Trigger the Cloud Function that starts a Cloud Asset export routinely"
  schedule    = "*/5  * * * *"

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.start_export.https_trigger_url

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler.email
    }
  }
}
