
resource "google_project_service" "enabled_services" {
  for_each = var.services  
  
  project = var.project
  service = each.key
}