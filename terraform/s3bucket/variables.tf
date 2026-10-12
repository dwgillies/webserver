variable "region" {
  description = "AWS Region. Projects in the new AWS experience can only use their assigned Region."
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS CLI profile used by the provider"
  type        = string
  default     = "agent-toolkit"
}

variable "bucket_prefix" {
  description = "Start of the bucket name; the account ID and Region are appended to make it globally unique"
  type        = string
  default     = "wgillies-tfstate"
}

variable "noncurrent_version_days" {
  description = "Days to keep old versions of state files before S3 deletes them"
  type        = number
  default     = 90
}
