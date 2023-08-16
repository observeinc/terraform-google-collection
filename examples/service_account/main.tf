resource "google_service_account" "this" {

  account_id  = "observe-collect"
  description = "Used to set up collection"
  project     = var.project
}

resource "google_project_iam_member" "this" {
  for_each = var.project_collection_roles

  project = var.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}

resource "google_folder_iam_member" "this" {
  for_each = var.folder_collection_roles

  folder = var.folder
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}