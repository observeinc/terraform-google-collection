locals {

}

# GKE cluster
resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = format(var.name_format, "gke")
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = data.google_compute_network.default.name
  subnetwork = data.google_compute_subnetwork.default.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.0.8.0/21"
    services_ipv4_cidr_block = "10.0.16.0/22"
  }
}

# # Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  project    = var.project_id
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    #    oauth_scopes = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.node_machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}




data "google_compute_network" "default" {
  name    = "default"
  project = var.project_id
}

data "google_compute_subnetwork" "default" {
  name    = "default"
  region  = var.region
  project = var.project_id
}

# resource "google_compute_subnetwork" "subnet" {
#   project       = var.project_id
#   name          = format(var.name_format, "gke-subnet")
#   region        = var.region
#   network       = data.google_compute_network.default.name
#   ip_cidr_range = "10.0.0.0/18"
# }


# # Kubernetes provider
# # The Terraform Kubernetes Provider configuration below is used as a learning reference only. 
# # It references the variables and resources provisioned in this file. 
# # We recommend you put this in another file -- so you can have a more modular configuration.
# # https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider.

# provider "kubernetes" {
#   load_config_file = "false"

#   host     = google_container_cluster.primary.endpoint
#   username = var.gke_username
#   password = var.gke_password

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

# resource "google_storage_bucket_object" "ips" {

#   name         = "ip/k8s_addresses.json"
#   bucket       = var.config_bucket_name
#   source       = "${dirname(path.module)}/compute/bucket/ip/k8s_addresses.json"
#   content_type = "text/plain; charset=utf-8"
# }
