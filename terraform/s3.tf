resource "aws_s3_bucket" "crc_resume_content_bucket" {
  bucket = "${var.s3_bucket_name_prefix}-${random_id.crc_resume_unique_id}"
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