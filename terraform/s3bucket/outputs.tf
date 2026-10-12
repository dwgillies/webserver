output "bucket_name" {
  description = "Use as the 'bucket' in other projects' backend \"s3\" blocks"
  value       = aws_s3_bucket.tfstate.bucket
}

output "region" {
  value = var.region
}
