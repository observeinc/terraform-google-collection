module "observe_gcp_collection" {
  source = "../../"
  # source = "observeinc/collection/google"

  name     = var.name
  resource = var.resource
  project_id = var.project_id
}

# module "google_project_service" {
#   for_each = {
#     for index, project in local.projects :
#     project.project_id => project
#   }

#   source             = "../enable_services"
#   project_id         = each.value.project_id
#   services_to_enable = var.metric_services
# }
