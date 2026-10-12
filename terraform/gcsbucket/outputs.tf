output "bucket_name" {
  description = "Use as the 'bucket' in other projects' backend \"gcs\" configuration"
  value       = google_storage_bucket.tfstate.name
}
