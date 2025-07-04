provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {
}

# This provider exists solely to create the NS records within the root domain so the subdomain
# created here will resolve. It has a different AWS profile, from the rest of Terraform.
# The required policies for the root domain account are in the DNS_ns_record_policy.json file.
# I used a special user (with only these permissions) and an Access Key within an AWS CLI profile.
provider "aws" {
  alias = "root_domain_acct"
  region = var.aws_region
  profile = var.site_root_domain_aws_profile
}

provider "random" {
}

provider "null" {}