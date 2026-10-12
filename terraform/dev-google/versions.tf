terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }

  # partial backend configuration: the bucket name contains the project ID,
  # which isn't known yet, so it is supplied at init time with
  #   terraform init -backend-config=backend.hcl
  # (see backend.hcl.example; the bucket comes from the gcsbucket project)
  backend "gcs" {
    prefix = "webserver/dev-google"
  }
}

# credentials come from: gcloud auth application-default login
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  default_labels = {
    project    = var.name
    managed-by = "terraform"
  }
}
