terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  # this project's own state stays local: the bucket it creates can't hold
  # the state needed to create it
}

# credentials come from: gcloud auth application-default login
provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    project    = "terraform-state"
    managed-by = "terraform"
  }
}
