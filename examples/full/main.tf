provider "google" {
  project = "YOUR_PROJECT_ID"
  region  = "YOUR_DEFAULT_REGION"
}

module "observe_gcp_collection" {
  source           = "observeinc/collection/google"
  name = var.name
  enable_extensions = true
}

