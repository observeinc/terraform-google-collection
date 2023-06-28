locals {

}

resource "google_compute_global_address" "my_ip" {
  name    = format(var.name_format, "static-load-balancer")
  project = var.project_id
}

module "http_load_balancer" {
  source                 = "./modules/http"
  project_id             = var.project_id
  name_format            = var.name_format
  target_group_instances = var.target_group_instances
  region                 = var.region
}

module "network_load_balancer" {
  source                 = "./modules/network"
  project_id             = var.project_id
  name_format            = var.name_format
  target_group_instances = var.target_group_instances
  region                 = var.region
}
