# create a cloud scheduler to call function on regular interval
resource "google_cloud_scheduler_job" "i" {
  region      = var.region
  project     = var.project_id
  name        = format(var.name_format, "job")
  description = "Triggers a Cloud Function"
  schedule    = var.schedule

  http_target {
    http_method = "POST"
    uri         = var.cloud_function_uri
    body        = var.body
    headers = {
      "Content-Type" = "application/json"
    }

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler.email
    }
  }
}

# create a service account for cloud scheduler
resource "google_service_account" "cloud_scheduler" {
  project     = var.project_id
  account_id  = format(var.name_format, "sched")
  description = "Allows the Cloud Scheduler job to trigger a Cloud Function"
}

# add service account to role
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = var.cloud_function_name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.cloud_scheduler.email}"

  lifecycle {
    replace_triggered_by = [
      null_resource.trigger
    ]
  }
}

resource "null_resource" "trigger" {
  triggers = { "dahash" = var.md5hash }
}
