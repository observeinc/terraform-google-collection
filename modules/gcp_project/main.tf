locals {
  services_to_enable = [
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddebugger.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "redis.googleapis.com",
    "memcache.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

resource "google_project" "project" {
  name       = var.project_name
  project_id = var.project_id
  #folder_id  = "437079763664"
  folder_id = var.folder_id

  billing_account = var.billing_account
}


resource "google_project_service" "project" {
  for_each = { for value in local.services_to_enable : value => value }
  project  = var.project_id
  service  = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  depends_on                 = [google_project.project]
}

resource "google_project_iam_binding" "project" {
  project = google_project.project.project_id
  role    = "roles/owner"

  members = setunion([
    ], var.project_owners
  )

  depends_on = [google_project.project]
}

resource "google_project_iam_binding" "project_editor" {
  project = google_project.project.project_id
  role    = "roles/editor"

  members = setunion([
    ], var.project_editors
  )

  depends_on = [google_project.project]
}
