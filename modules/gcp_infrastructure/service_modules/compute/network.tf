# add nat so private instance can reach internet for package downloads
data "google_compute_network" "default" {
  name    = "default"
  project = var.project_id
}

# data "google_compute_subnetwork" "uswest1" {
#   for_each = local.regions
#   project  = var.project_id
#   name     = "default"
#   region   = each.value
# }

locals {
  regions = { for key, value in distinct([var.region, "us-central1", "us-east1"]) : key => value }
}

resource "google_compute_router" "router" {
  for_each = local.regions
  project  = var.project_id
  name     = format(var.name_format, "${each.value}-nat-router")
  region   = each.value
  network  = data.google_compute_network.default.id

  bgp {
    asn = 64514
  }
}


resource "google_compute_router_nat" "nat" {
  for_each                           = local.regions
  project                            = var.project_id
  name                               = format(var.name_format, "my-router-nat")
  router                             = google_compute_router.router[each.key].name
  region                             = each.value
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}