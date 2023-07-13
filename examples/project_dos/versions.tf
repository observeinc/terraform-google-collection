terraform {
  required_version = ">= 0.12.21"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 1"
    }
  }
}
