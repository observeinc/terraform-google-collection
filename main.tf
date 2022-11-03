locals {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "this" {
  project = var.project_id
  name    = var.name
  labels  = var.labels

  message_storage_policy {
    allowed_persistence_regions = [local.region]
  }
}

resource "google_pubsub_subscription" "this" {
  project = var.project_id
  name    = var.name
  labels  = var.labels
  topic   = google_pubsub_topic.this.name

  ack_deadline_seconds       = var.pubsub_ack_deadline_seconds
  message_retention_duration = var.pubsub_message_retention_duration
  retry_policy {
    minimum_backoff = var.pubsub_minimum_backoff
    maximum_backoff = var.pubsub_maximum_backoff
  }
}

resource "google_logging_project_sink" "this" {
  project                = var.project_id
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

resource "google_service_account" "poller" {
  project     = var.project_id
  account_id  = "${var.name}-poll"
  description = "A service account for the Observe Pub/Sub and Logging pollers"
}

resource "google_project_iam_member" "poller" {
  for_each = toset([
    "roles/pubsub.subscriber",
    "roles/monitoring.viewer",
    "roles/cloudasset.viewer",
    "roles/browser",
  ])

  project = local.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.poller.email}"
}

resource "google_service_account_key" "poller" {
  service_account_id = google_service_account.poller.name
}

module "extensions" {
  source = "./collection_extensions/cloud_function_to_pubsub"
  project_id = var.project_id
  region = var.region
  extensions_to_include = [
    "export-instance-groups",
    "export-service-accounts",
    "export-cloud-scheduler"
  ]
  src_path = "${path.module}/collection_extensions/src"
}
