resource "google_project_service" "storage" {
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# Cloud Storage encrypts at rest and only serves its API over HTTPS by
# default, so there is no equivalent of the S3 encryption and TLS-only policy
resource "google_storage_bucket" "tfstate" {
  name     = "${var.bucket_prefix}-${var.project_id}"
  location = var.region

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # keep every version of every state file so a bad apply can be rolled back
  versioning {
    enabled = true
  }

  # old versions are only needed for recovery; don't keep them forever
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = var.noncurrent_version_days
    }
    action {
      type = "Delete"
    }
  }

  # losing this bucket means losing track of everything the other projects
  # created; remove this guard deliberately if you ever need to delete it
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.storage]
}
