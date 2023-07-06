
locals {
  services_to_enable = var.services_to_enable
}

resource "google_project_service" "project" {
  for_each = { for value in local.services_to_enable : value => value }
  project  = var.project_id
  service  = each.value

  timeouts {
    create = "2m"
    update = "2m"
  }
  disable_dependent_services = true
}
