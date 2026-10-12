terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # this project's own state stays local: the bucket it creates can't hold
  # the state needed to create it
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = "terraform-state"
      ManagedBy = "terraform"
    }
  }
}
