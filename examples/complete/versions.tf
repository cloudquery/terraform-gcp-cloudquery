terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.21"
    }
  }
  required_version = ">= 0.13"
}