terraform {
  required_version = ">= 0.15"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5"
    }
  }
}