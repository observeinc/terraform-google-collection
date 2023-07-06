data "google_projects" "my_folder_projects" {
  filter = "parent.id:${data.google_project.service_project.folder_id} lifecycleState:ACTIVE"
}

data "google_project" "service_project" {
  project_id = var.project_id
}

locals {
  projects = data.google_projects.my_folder_projects.projects
}

resource "google_monitoring_monitored_project" "primary" {
  for_each = {
    for index, project in local.projects :
    project.project_id => project if project.project_id != var.project_id
  }
  metrics_scope = var.project_id
  name          = each.value.project_id
}

module "observe_gcp_collection" {
  #source = "../../"
  source = "observeinc/collection/google"

  name     = var.name
  resource = var.resource
  project_id = var.project_id
}