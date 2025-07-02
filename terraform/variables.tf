variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS CLI profile to use for deploying resources"
  type        = string
}

variable "random_id_byte_length" {
  description = "The byte length for the random ID used in resource names"
  type        = number
  default     = 8
}

variable "s3_bucket_name_prefix" {
  description = "Prefix for the S3 bucket names"
  type        = string
  default     = "peter-mescher-crc-resume-content"
}

variable "local_resume_content_path" {
  description = "The local path to the resume content to upload to S3"
  type        = string
}

variable "site_base_domain" {
  description = "The base domain for the site"
  type        = string
}

variable "site_root_domain_credentials" {
  description = "The aws CLI profile to use for the root domain account for R53 validation records"
  type        = string
}

variable "site_domain_prefix" {
  description = "The prefix for the site domain, e.g., 'dev' for dev.mescher.net"
  type        = string 
}

variable "site_root_zone_id" {
  description = "The Route 53 zone ID for the root domain"
  type        = string
}