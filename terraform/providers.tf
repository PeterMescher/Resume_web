provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {
}

provider "aws" {
  alias = "root_domain_acct"
  region = var.aws_region
  profile = var.site_root_domain_credentials
}

provider "random" {
}