terraform {
  required_version = ">= 0.12.21"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.15"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
