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

# All these blanks are in the .tfbackend file; unlike the rest of Terraform blocks, this one cannot reference variables.  
  backend "s3" {
    bucket         = ""
    key            = ""
    region         = ""
    encrypt        = true
    profile        = ""
  }
}