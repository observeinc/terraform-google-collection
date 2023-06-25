terraform {
  required_providers {
    # observe = {
    #   source  = "terraform.observeinc.com/observeinc/observe"
    #   version = "~> 0.13"
    # }
    google = {
      source  = "hashicorp/google"
      version = "<= 4.67.0"
    }
  }
  required_version = ">= 1.3.0"
}

# provider "google" {
#   project = var.project_id
#   region  = var.region
# }
