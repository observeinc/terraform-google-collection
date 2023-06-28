locals {
  load_test_region = "us-east1"
}

resource "google_cloud_run_v2_job" "loadtest" {
  name         = "loadtest"
  location     = local.load_test_region
  launch_stage = "BETA"

  template {
    template {
      containers {
        image = data.google_container_registry_image.loadtest.image_url
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
      }
      timeout = "2700s" # 45 minutes, since the test runs for 30 minutes
    }
    task_count = 1
  }
  depends_on = [
    google_cloud_run_v2_service.server
  ]
}

resource "google_service_account" "scheduler_sa" {
  account_id   = "avocano-loadtest-scheduler-sa"
  description  = "Cloud Scheduler service account; used to trigger scheduled Cloud Run jobs."
  display_name = "avocano-loadtest-scheduler-sa"
  depends_on = [
    google_cloud_run_v2_job.loadtest
  ]
}

resource "google_cloud_run_v2_job_iam_member" "invoker" {
  project  = var.project_id
  location = local.load_test_region
  name     = google_cloud_run_v2_job.loadtest.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler_sa.email}"
}
resource "google_cloud_scheduler_job" "trigger_loadtest" {
  name             = "avocano-scheduled-loadtest"
  description      = "Invoke a Cloud Run container on a schedule."
  schedule         = "0 * * * *"
  time_zone        = "UTC"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "https://${local.load_test_region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.project.number}/jobs/${google_cloud_run_v2_job.loadtest.name}:run"

    oauth_token {
      service_account_email = google_service_account.scheduler_sa.email
    }
  }
}
