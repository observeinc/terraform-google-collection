locals {
  project = data.google_client_config.this.project
  region  = data.google_client_config.this.region
}

data "google_client_config" "this" {}

resource "google_storage_bucket" "asset_inventory_export" {
  name   = "${var.name}-asset-inventory-export"
  labels = var.labels

  force_destroy = true
  location      = local.region

  lifecycle_rule {
    condition {
      age = var.storage_retention_in_days
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_pubsub_topic" "this" {
  name   = var.name
  labels = var.labels

  message_storage_policy {
    allowed_persistence_regions = [local.region]
  }
}

resource "google_pubsub_subscription" "this" {
  name   = var.name
  labels = var.labels
  topic  = google_pubsub_topic.this.name

  ack_deadline_seconds       = var.pubsub_ack_deadline_seconds
  message_retention_duration = var.pubsub_message_retention_duration
  retry_policy {
    minimum_backoff = var.pubsub_minimum_backoff
    maximum_backoff = var.pubsub_maximum_backoff
  }
}

resource "google_cloud_asset_project_feed" "this" {
  // Content types "OS_INVENTORY" and "RELATIONSHIP" are not supported yet by
  // the GCP terraform provider
  for_each = toset(var.asset_content_types)

  feed_id      = "${var.name}-${replace(lower(each.value), "_", "-")}" // underscores not allowed in id
  asset_names  = var.asset_names
  asset_types  = var.asset_types
  content_type = each.value

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.this.id
    }
  }
}

resource "google_logging_project_sink" "this" {
  name                   = var.name
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.this.id}"
  unique_writer_identity = true
  filter                 = var.logging_filter

  description = "Export logs to the Observe PubSub topic"

  dynamic "exclusions" {
    for_each = var.logging_exclusions
    content {
      name        = exclusions.name
      description = exclusions.description
      filter      = exclusions.filter
      disabled    = exclusions.disabled
    }
  }
}

resource "google_pubsub_topic_iam_member" "sink_pubsub" {
  project = google_pubsub_topic.this.project
  topic   = google_pubsub_topic.this.name
  role    = "roles/pubsub.publisher"
  member  = google_logging_project_sink.this.writer_identity
}

resource "google_service_account" "cloud_functions" {
  account_id  = "${var.name}-func"
  description = "A service account for the Observe Cloud Functions"
}

resource "google_project_iam_member" "cloud_functions" {
  for_each = toset([
    "roles/cloudasset.viewer",
    "roles/storage.objectViewer",
    "roles/pubsub.publisher",
  ])

  project = local.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}

resource "google_cloudfunctions_function" "start_export" {
  name   = "${var.name}-start-export"
  labels = var.labels
  region = local.region

  description = "Trigger a Cloud Asset export to Cloud Storage"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "StartExport"
  source_archive_bucket = "prototype-luke-asset-inventory"
  source_archive_object = "cloudfunctions.zip"

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" // Needed so that Cloud Scheduler can trigger the Cloud Function

  environment_variables = {
    "BUCKET"     = google_storage_bucket.asset_inventory_export.name
    "PROJECT_ID" = local.project
    "TOPIC_ID"   = google_pubsub_topic.this.name

    "ASSET_NAMES"   = jsonencode(var.asset_names)
    "ASSET_TYPES"   = jsonencode(var.asset_types)
    "CONTENT_TYPES" = jsonencode(var.asset_content_types)
  }

  max_instances = var.cloud_function_max_instances
}

resource "google_cloudfunctions_function" "process_export" {
  name   = "${var.name}-process-export"
  labels = var.labels
  region = local.region

  description = "Write the contents of a Cloud Asset export to Pub/Sub"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "ProcessExport"
  source_archive_bucket = "prototype-luke-asset-inventory"
  source_archive_object = "cloudfunctions.zip"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.asset_inventory_export.name
  }

  environment_variables = {
    "BUCKET"     = google_storage_bucket.asset_inventory_export.name
    "PROJECT_ID" = local.project
    "TOPIC_ID"   = google_pubsub_topic.this.name
  }

  max_instances = var.cloud_function_max_instances
}

resource "google_service_account" "cloud_scheduler" {
  account_id  = "${var.name}-sched"
  description = "A service account to allow the Cloud Scheduler job to trigger a Cloud Function"
}

resource "google_project_iam_member" "cloud_scheduler_cloud_function_invoker" {
  project = local.project
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloud_scheduler.email}"
}

resource "google_cloud_scheduler_job" "this" {
  name        = var.name
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

resource "google_service_account" "poller" {
  account_id  = "${var.name}-poll"
  description = "A service account for the Observe Pub/Sub and Logging pollers"
}

resource "google_project_iam_member" "poller" {
  for_each = toset([
    "roles/pubsub.subscriber",
    "roles/monitoring.viewer",
  ])

  project = local.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.poller.email}"
}

resource "google_service_account_key" "poller" {
  service_account_id = google_service_account.poller.name
}
