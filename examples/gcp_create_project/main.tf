
module "gcp_service_proj" {
  source          = "../../modules/gcp_project"
  org_id          = var.org_id
  folder_id       = var.folder_id
  project_id      = var.project_id
  project_name    = var.project_id
  billing_account = var.billing_account
  project_owners  = var.project_owners
  #project_editors = ["serviceAccount:1009076385151@cloudservices.gserviceaccount.com"]
}