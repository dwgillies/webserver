terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # bucket comes from the s3bucket project's bucket_name output; backend
  # blocks can't use variables, so the values are written out here
  backend "s3" {
    bucket       = "wgillies-tfstate-121728644016-us-east-2"
    key          = "webserver/dev-aws/terraform.tfstate"
    region       = "us-east-2"
    profile      = "agent-toolkit"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = var.name
      ManagedBy = "terraform"
    }
  }
}
