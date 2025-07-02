resource "aws_s3_bucket" "crc_resume_content_bucket" {
  bucket = "${var.s3_bucket_name_prefix}-${random_id.crc_resume_unique_id.hex}"
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

locals {
  site_dir      = "${var.local_resume_content_path}"
  site_files    = fileset(local.site_dir, "**")
  site_hash     = sha256(join("", [
    for f in local.site_files :
    filesha256("${local.site_dir}/${f}")
  ]))
}

resource "null_resource" "upload_static_site" {
  triggers = {
    content_hash = local.site_hash
  }
  provisioner "local-exec" {
    command = "aws s3 sync ${var.local_resume_content_path} s3://${aws_s3_bucket.crc_resume_content_bucket.bucket} --profile ${var.aws_profile} --region ${var.aws_region} --delete"
  }
  depends_on = [
    aws_s3_bucket_policy.crc_resume_s3_policy,
  ]
}

resource "null_resource" "cloudfront_invalidation" {
  triggers = {
    content_hash = local.site_hash
  }

  provisioner "local-exec" {
    command = <<EOT
      aws cloudfront create-invalidation \
        --distribution-id ${aws_cloudfront_distribution.crc_resume_cloudfront.id} \
        --paths "/*" --profile ${var.aws_profile}
    EOT
  }

  depends_on = [null_resource.upload_static_site]
}