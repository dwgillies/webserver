variable "project_id" {
  description = "Google Cloud project ID (not the project name or number)"
  type        = string
}

variable "region" {
  description = "Region for the bucket"
  type        = string
  default     = "us-west1"
}

variable "bucket_prefix" {
  description = "Start of the bucket name; the project ID is appended to make it globally unique"
  type        = string
  default     = "wgillies-tfstate"
}

variable "noncurrent_version_days" {
  description = "Days to keep old versions of state files before they are deleted"
  type        = number
  default     = 90
}
