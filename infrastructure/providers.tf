terraform {
  required_version = "~> 1.16.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.1.0"
    }
  }
  backend "gcs" {
    bucket = "market-pulse-state-bucket"
    prefix = "terraform/state"
    encrypt = true
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}