resource "google_service_account" "this" {

  account_id  = "terraform-observe-collect-sa"
  description = "Used to set up collection"
  project     = var.project
}

# Grant yourself the Service Token Creator Role
resource "google_service_account_iam_member" "sa_token_creator_role" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.current_user}"
}

###############
#
# Uncomment the first section for a service account that can deploy to a project
# and uncomment the second section for folder collection.  If you are deploying to
# a folder, you need to add the folder id to the service_account.auto.tfvars file as well.
# 
# The default is to use a project 

################

resource "google_project_iam_member" "this" {
  for_each = var.project_collection_roles

  project = var.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.this.email}"
}

# resource "google_folder_iam_member" "this" {
#   for_each = var.folder_collection_roles

#   folder = var.folder
#   role    = each.key
#   member  = "serviceAccount:${google_service_account.this.email}"
# }

