
locals {
  services_to_enable = var.services_to_enable
}

resource "google_project_service" "project" {
  for_each = { for value in local.services_to_enable : value => value }
  project  = var.project_id
  service  = try(each.value)

  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services = true
  disable_on_destroy         = true
}
