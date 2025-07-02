provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias = "root_domain_acct"
  region = var.aws_region
  profile = var.site_root_domain_credentials
}

provider "random" {
}