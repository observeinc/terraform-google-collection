resource "google_service_account" "this" {

  account_id  = "observe-collect"
  description = "Used to set up collection"
  project     = var.project
}

###############
#
# Uncomment the first section for a service account that can deploy to a project
# and uncomment the second section for folder collection.  If you are deploying to
# a folder, you need to add the folder id to the service_account.auto.tfvars file as well.
#
################

# resource "google_project_iam_member" "this" {
#   for_each = var.project_collection_roles

#   project = var.project
#   role    = each.key
#   member  = "serviceAccount:${google_service_account.this.email}"
# }

# resource "google_folder_iam_member" "this" {
#   for_each = var.folder_collection_roles

#   folder = var.folder
#   role    = each.key
#   member  = "serviceAccount:${google_service_account.this.email}"
# }