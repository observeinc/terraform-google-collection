resource "google_service_account" "cloudfunction" {
  count = var.enable_function ? 1 : 0

  account_id  = "${var.name}-func"
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

resource "google_cloudfunctions_function" "this" {
  count = var.enable_function ? 1 : 0

  name                  = var.name
  description           = "Polls data from the Google Cloud API and sends to the Observe Pub/Sub topic."
  service_account_email = google_service_account.cloudfunction[0].email

  runtime = "python310"
  environment_variables = merge({
    "PARENT"   = var.resource
    "TOPIC_ID" = google_pubsub_topic.this.id
    "VERSION"  = "${var.function_bucket}/${var.function_object}"
  }, var.function_disable_logging ? { "DISABLE_LOGGING" : "ok" } : {})

  trigger_http     = true
  ingress_settings = "ALLOW_ALL" # Needed for Cloud Scheduler to work

  available_memory_mb = var.function_available_memory_mb
  timeout             = var.function_timeout
  max_instances       = var.function_max_instances

  source_archive_bucket = var.function_bucket
  source_archive_object = var.function_object
  entry_point           = "main"

  labels = var.labels
}


resource "google_service_account" "cloud_scheduler" {
  count = var.enable_function ? 1 : 0

  account_id  = "${var.name}-sched"
  description = "Allows the Cloud Scheduler job to trigger a Cloud Function"
}

resource "google_cloudfunctions_function_iam_member" "cloud_scheduler" {
  count = var.enable_function ? 1 : 0

  cloud_function = google_cloudfunctions_function.this[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.cloud_scheduler[0].email}"
}

resource "google_cloud_scheduler_job" "this" {
  count = var.enable_function ? 1 : 0

  name        = var.name
  description = "Triggers the Cloud Function"
  schedule    = var.function_schedule

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.this[0].https_trigger_url

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler[0].email
    }
  }
}
