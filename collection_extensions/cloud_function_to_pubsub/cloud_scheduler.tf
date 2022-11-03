resource "google_service_account" "cloud_scheduler" {
  project     = var.project_id
  account_id  = format(var.name_format, "sched")
  description = "A service account to allow the Cloud Scheduler job to trigger a Cloud Function"
}

resource "google_project_iam_member" "cloud_scheduler_cloud_function_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloud_scheduler.email}"
}

resource "google_cloud_scheduler_job" "this" {
  for_each    = { for key, value in local.entry_point : key => value }
  project     = var.project_id
  region      = var.region
  name        = format(var.name_format, each.value.entry_point)
  description = "Trigger the Cloud Function that starts a instance group list export routinely"
  schedule    = "*/5  * * * *"


  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.function[each.key].https_trigger_url

    oidc_token {
      service_account_email = google_service_account.cloud_scheduler.email
    }

    # oauth_token {
    #   service_account_email = google_service_account.cloud_scheduler.email
    # }
  }
}