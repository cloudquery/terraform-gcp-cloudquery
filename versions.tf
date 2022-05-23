terraform {
  required_version = ">= 0.15"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.21"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}