resource "aws_cloudfront_distribution" "crc_resume_cloudfront" {
  origin {
    domain_name = aws_s3_bucket.crc_resume_content_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.crc_resume_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for CRC resume content"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [
    "www.${var.site_domain_prefix}.${var.site_base_domain}",
    "${var.site_domain_prefix}.${var.site_base_domain}",
  ]

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = crc_resume_certificate.arn
    ssl_support_method             = "sni-only"
  }
}