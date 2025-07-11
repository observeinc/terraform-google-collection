
resource "random_id" "cloudtasks_queue" {
  byte_length = 8
}

resource "google_service_account" "cloudfunction" {
  count = var.enable_function ? 1 : 0

  account_id  = "${local.name}-func"
  description = "Used by the Observe Cloud Functions"
}

resource "google_project_iam_member" "cloudfunction" {
  for_each = var.enable_function && local.resource_type == "projects" ? var.function_roles : toset([])

  project = data.google_project.this.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudfunction[0].email}"
}

resource "google_folder_iam_member" "cloudfunction" {
  for_each = var.enable_function && local.resource_type == "folders" ? var.function_roles : toset([])

  folder = var.resource
  role   = each.key
  member = "serviceAccount:${google_service_account.cloudfunction[0].email}"
}

resource "google_organization_iam_member" "cloudfunction" {
  for_each = var.enable_function && local.resource_type == "organizations" ? var.function_roles : toset([])

  org_id = var.resource
  role   = each.key
  member = "serviceAccount:${google_service_account.cloudfunction[0].email}"
}


resource "google_pubsub_topic_iam_member" "cloudfunction_pubsub" {
  count = var.enable_function ? 1 : 0

  topic  = google_pubsub_topic.this.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.cloudfunction[0].email}"
}

resource "google_storage_bucket" "this" {
  name     = "${var.project_id}-${local.name}"
  location = "US"

  force_destroy = true
  # Since the bucket is just a temporary storage for asset export objects until 
  # the function can process them, we want to implicitly delete any leftover objects
  # if Terraform plans to remove the bucket

  # added for maintaining the bucket file and folder lifecycle
  lifecycle_rule {
    condition {
      age = var.bucket_lifecycle_delete_days
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = var.bucket_lifecycle_abort_upload_days
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }

}

resource "google_storage_bucket_iam_member" "bucket_iam" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.cloudfunction[0].email}"
}

resource "google_cloudfunctions_function" "this" {
  count = var.enable_function ? 1 : 0

  name                  = "${local.name}_assets_to_gcs"
  description           = "Polls data from the Google Cloud API and sends to the Observe Pub/Sub topic."
  service_account_email = google_service_account.cloudfunction[0].email

  runtime = "python310"
  environment_variables = merge({
    "OUTPUT_BUCKET"                    = "gs://${google_storage_bucket.this.name}",
    "PARENT"                           = var.resource,
    "PROJECT"                          = var.project_id
    "TOPIC_ID"                         = google_pubsub_topic.this.id,
    "VERSION"                          = "${var.function_bucket}/${var.function_object}",
    "LOG_LEVEL"                        = var.cloud_function_debug_level,
    "GCP_REGION"                       = var.gcp_region,
    "TASK_QUEUE"                       = google_cloud_tasks_queue.task_queue.name,
    "SERVICE_ACCOUNT_EMAIL"            = google_service_account.cloudfunction[0].email,
    "GCS_TO_PUBSUB_CLOUD_FUNCTION_URI" = google_cloudfunctions_function.gcs_function[0].https_trigger_url
  }, var.function_disable_logging ? { "DISABLE_LOGGING" : "ok" } : {})

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" # Needed for Cloud Scheduler to work

  available_memory_mb = var.function_available_memory_mb
  timeout             = var.function_timeout
  max_instances       = var.function_max_instances

  source_archive_bucket = var.function_bucket
  source_archive_object = var.function_object
  entry_point           = "export_assets"

  labels = var.labels
}

resource "google_cloudfunctions_function" "gcs_function" {
  count = var.enable_function ? 1 : 0

  name                  = "${local.name}_gcs_to_pubsub"
  description           = "Triggered by changes in the Google Cloud Storage bucket and sends data to the Observe Pub/Sub topic."
  service_account_email = google_service_account.cloudfunction[0].email

  runtime = "python310"
  environment_variables = merge({
    "OUTPUT_BUCKET"                    = "gs://${google_storage_bucket.this.name}",
    "PROJECT"                          = var.project_id
    "PARENT"                           = var.resource,
    "TOPIC_ID"                         = google_pubsub_topic.this.id,
    "VERSION"                          = "${var.function_bucket}/${var.function_object}",
    "LOG_LEVEL"                        = var.cloud_function_debug_level,
    "GCP_REGION"                       = var.gcp_region,
    "TASK_QUEUE"                       = google_cloud_tasks_queue.task_queue.name,
    "SERVICE_ACCOUNT_EMAIL"            = google_service_account.cloudfunction[0].email
    "GCS_TO_PUBSUB_CLOUD_FUNCTION_URI" = "not_applicable"
  }, var.function_disable_logging ? { "DISABLE_LOGGING" : "ok" } : {})

  available_memory_mb = var.function_available_memory_mb
  timeout             = var.function_timeout
  max_instances       = var.function_max_instances

  source_archive_bucket = var.function_bucket
  source_archive_object = var.function_object
  entry_point           = "gcs_to_pubsub"

  labels       = var.labels
  trigger_http = true
}

resource "google_storage_bucket_iam_member" "gcs_function_bucket_iam" {
  count = var.enable_function ? 1 : 0

  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloudfunction[0].email}"
}

resource "google_service_account" "cloud_scheduler" {
  count = var.enable_function ? 1 : 0

  account_id  = "${local.name}-sched"
  description = "Allows the Cloud Scheduler job to trigger a Cloud Function"
}

resource "google_cloudfunctions_function_iam_member" "cloud_scheduler" {
  count = var.enable_function ? 1 : 0

  cloud_function = google_cloudfunctions_function.this[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.cloud_scheduler[0].email}"
}

resource "google_cloud_scheduler_job" "this" {
  name        = local.name
  description = "Triggers the Cloud Function"
  schedule    = var.function_schedule_frequency

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.this[0].https_trigger_url

    headers = {
      Content-Type = "application/json"
    }

    body = base64encode("{}")

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler[0].email
    }
  }
}

resource "google_cloudfunctions_function" "rest_of_assets" {
  count = var.enable_function ? 1 : 0

  name                  = "${local.name}_observe_rest_of_assets"
  description           = "Function that collections assets not capture by asset feed or asset exports."
  service_account_email = google_service_account.cloudfunction[0].email

  runtime = "python310"
  environment_variables = merge({
    "OUTPUT_BUCKET"                    = "gs://${google_storage_bucket.this.name}",
    "PARENT"                           = var.resource,
    "PROJECT"                          = var.project_id
    "TOPIC_ID"                         = google_pubsub_topic.this.id,
    "VERSION"                          = "${var.function_bucket}/${var.function_object}",
    "LOG_LEVEL"                        = var.cloud_function_debug_level,
    "GCP_REGION"                       = var.gcp_region,
    "TASK_QUEUE"                       = google_cloud_tasks_queue.task_queue.name,
    "SERVICE_ACCOUNT_EMAIL"            = google_service_account.cloudfunction[0].email,
    "GCS_TO_PUBSUB_CLOUD_FUNCTION_URI" = google_cloudfunctions_function.gcs_function[0].https_trigger_url
  }, var.function_disable_logging ? { "DISABLE_LOGGING" : "ok" } : {})

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" # Needed for Cloud Scheduler to work

  available_memory_mb = var.function_available_memory_mb
  timeout             = var.function_timeout
  max_instances       = var.function_max_instances

  source_archive_bucket = var.function_bucket
  source_archive_object = var.function_object
  entry_point           = "rest_of_assets"

  labels = var.labels
}

resource "google_cloud_scheduler_job" "rest_of_assets" {
  name        = "${local.name}-more-assets-job"
  description = "Triggers the rest of assets Cloud Function"
  schedule    = var.function_schedule_frequency_rest_of_assets

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.rest_of_assets[0].https_trigger_url

    headers = {
      Content-Type = "application/json"
    }

    body = base64encode("{}")

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler[0].email
    }
  }
}

resource "google_cloudfunctions_function_iam_member" "cloud_scheduler_rest_of_assets" {
  count = var.enable_function ? 1 : 0

  cloud_function = google_cloudfunctions_function.rest_of_assets[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.cloud_scheduler[0].email}"
}

resource "google_cloud_tasks_queue" "task_queue" {
  name     = "${local.name}-${random_id.cloudtasks_queue.hex}"
  location = var.gcp_region

  rate_limits {
    max_concurrent_dispatches = var.max_concurrent_dispatches
    max_dispatches_per_second = var.max_dispatches_per_second
  }

  retry_config {
    max_attempts       = var.max_attempts
    max_retry_duration = var.max_retry_duration
    min_backoff        = var.min_backoff
  }
}
