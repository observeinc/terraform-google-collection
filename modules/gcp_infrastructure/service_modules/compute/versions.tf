terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.37.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
  required_version = ">= 1.3.0"
}

