locals {
  project = data.google_client_config.this.project
  region  = data.google_client_config.this.region

  function_env_vars = {
    "NAME"       = var.name
    "BUCKET"     = google_storage_bucket.asset_inventory_export.name
    "PROJECT_ID" = local.project
    "TOPIC_ID"   = google_pubsub_topic.this.name

    "ASSET_TYPES"   = jsonencode(var.asset_types)
    "CONTENT_TYPES" = jsonencode(var.asset_content_types)
  }
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
    "roles/cloudasset.owner",
    "roles/storage.objectViewer",
    "roles/pubsub.publisher",
  ])

  project = local.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_functions.email}"
}


resource "google_storage_bucket" "function_code" {
  name     = "${var.name}-code"
  labels   = var.labels
  location = local.region
}

data "archive_file" "function_code" {
  type        = "zip"
  source_dir  = "${path.module}/cloudfunctions/"
  output_path = "${path.module}/cloudfunctions.zip"
}

resource "google_storage_bucket_object" "function_code" {
  bucket = google_storage_bucket.function_code.name
  # The name gets updated whenever the code changes, and Cloud Functions referencing this resource will get updated too
  name   = "cloudfunctions-${data.archive_file.function_code.output_sha}.zip"
  source = data.archive_file.function_code.output_path
}

resource "google_cloudfunctions_function" "start_export" {
  name   = "${var.name}-start-export"
  labels = var.labels

  description = "Trigger a Cloud Asset export to Cloud Storage"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "StartExport"
  source_archive_bucket = google_storage_bucket.function_code.name
  source_archive_object = google_storage_bucket_object.function_code.name

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" # Needed so that Cloud Scheduler can trigger the Cloud Function

  environment_variables = local.function_env_vars

  max_instances = var.cloud_function_max_instances
}

resource "google_cloudfunctions_function" "process_export" {
  name   = "${var.name}-process-export"
  labels = var.labels

  description = "Write the contents of a Cloud Asset export to Pub/Sub"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "ProcessExport"
  source_archive_bucket = google_storage_bucket.function_code.name
  source_archive_object = google_storage_bucket_object.function_code.name

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.asset_inventory_export.name
  }

  environment_variables = local.function_env_vars

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

# Note: while we could use the "google_cloud_asset_project_feed" terraform resource,
# it means a user cannot use user credentials in the provider, complicating setup.
resource "google_cloudfunctions_function" "feed_management" {
  for_each = {
    "create" : {
      event_type = "google.storage.object.finalize"
    }
    "delete" : {
      event_type = "google.storage.object.delete"
    }
  }

  name   = "${var.name}-feed-${each.key}"
  labels = var.labels

  description = "Create and delete a Cloud Asset Feed"

  service_account_email = google_service_account.cloud_functions.email

  runtime               = "go116"
  entry_point           = "ManageFeeds"
  source_archive_bucket = google_storage_bucket.function_code.name
  source_archive_object = google_storage_bucket_object.function_code.name

  event_trigger {
    event_type = each.value.event_type
    resource   = google_storage_bucket.feed_management.name
  }

  environment_variables = local.function_env_vars

  max_instances = var.cloud_function_max_instances
}


resource "google_storage_bucket" "feed_management" {
  name     = "${var.name}-feed-management"
  location = local.region
  labels   = var.labels
}

resource "time_sleep" "wait_object_notification" {
  create_duration  = "10s"
  destroy_duration = "10s"

  # triggers should change whenever we re-create the object below
  triggers = local.function_env_vars

  depends_on = [google_cloudfunctions_function.feed_management]
}

resource "google_storage_bucket_object" "feed_management" {
  bucket  = google_storage_bucket.feed_management.name
  name    = sha256(jsonencode(local.function_env_vars))
  content = "placeholder"

  depends_on = [time_sleep.wait_object_notification]
}
