# PROVIDERS
terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<= 4.67.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
  required_version = ">= 1.3.0"
}
