terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.2.0"
  
  backend "s3" {
    bucket         = "peter-mescher-crc-dev-terraform"
    key            = "terraform/state"
    region         = "us-east-1"
    encrypt        = true
    profile        = "terraform_dev"
  }
}