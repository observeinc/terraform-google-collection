locals {
  resource_type = split("/", var.resource)[0]
  resource_id   = split("/", var.resource)[1]

  writer_identity = (
    local.resource_type == "projects" ?
    google_logging_project_sink.this[0].writer_identity : (
      local.resource_type == "folders" ?
      google_logging_folder_sink.this[0].writer_identity :
      google_logging_organization_sink.this[0].writer_identity
    )
  )
}

data "google_project" "this" {
  project_id = local.resource_type == "projects" ? local.resource_id : null
}

data "google_folder" "this" {
  folder = local.resource_type == "folders" ? local.resource_id : null
}

resource "google_pubsub_topic" "this" {
  name   = var.name
  labels = var.labels
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

resource "google_logging_project_sink" "this" {
  count       = local.resource_type == "projects" ? 1 : 0
  name        = var.name
  project     = data.google_project.this.project_id
  destination = "pubsub.googleapis.com/${google_pubsub_topic.this.id}"
  filter      = var.logging_filter

  description = "Exports logs to the Observe Pub/Sub topic"

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

resource "google_logging_folder_sink" "this" {
  count = local.resource_type == "folders" ? 1 : 0

  name             = var.name
  folder           = data.google_folder.this.folder_id
  destination      = "pubsub.googleapis.com/${google_pubsub_topic.this.id}"
  filter           = var.logging_filter
  include_children = var.folder_include_children

  description = "Exports logs to the Observe Pub/Sub topic"

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

resource "google_logging_organization_sink" "this" {
  count = local.resource_type == "organizations" ? 1 : 0

  name        = var.name
  org_id      = local.resource_id
  destination = "pubsub.googleapis.com/${google_pubsub_topic.this.id}"
  filter      = var.logging_filter

  description = "Exports logs to the Observe Pub/Sub topic"

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
  topic  = google_pubsub_topic.this.name
  role   = "roles/pubsub.publisher"
  member = local.writer_identity
}

resource "google_service_account" "poller" {
  account_id  = "${var.name}-poll"
  description = "A service account for the Observe Pub/Sub and Logging pollers"
}

resource "google_pubsub_subscription_iam_member" "poller_pubsub" {
  subscription = google_pubsub_subscription.this.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.poller.email}"
}

resource "google_project_iam_member" "poller" {
  for_each = var.poller_roles

  project = data.google_project.this.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.poller.email}"
}

resource "google_service_account_key" "poller" {
  service_account_id = google_service_account.poller.name
}
