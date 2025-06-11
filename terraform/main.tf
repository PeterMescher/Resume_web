terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "=> 1.2.0"
  backend "s3" {
    bucket         = "peter-mescher-crc-dev-terraform"
    key            = "terraform/state"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
    region = "us-east-1"
  }

provider "random" {
  }

resource "random_id" "crc_resume_unique_id" {
    byte_length = 8
  }

resource "aws_s3_bucket" "crc_resume_content_bucket" {
  bucket = "peter-mescher-crc-resume-content-${random_id.crc_resume_unique_id.hex}"
}

resource "aws_s3_bucket_policy" "crc_resume_s3_policy" {
  bucket = aws_s3_bucket.crc_resume_content_bucket.bucket
  policy = data.aws_iam_policy_document.crc_resume_allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "crc_resume_allow_access_from_cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.crc_resume_content_bucket.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.crc_resume_cloudfront.arn,
      ]
    }
  }
}

resource "aws_cloudfront_distribution" "crc_resume_cloudfront" {
  origin {
    domain_name = aws_s3_bucket.crc_resume_content_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.crc_resume_oai.cloudfront_access_identity_path
    }
  }


