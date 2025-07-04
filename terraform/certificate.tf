# This file contains the configuration for the AWS ACM certificate and Route 53 DNS certificate validation records
# It does not contain the R53 records we actually use to serve the site, those are in route53.tf

resource "aws_acm_certificate" "crc_resume_certificate" {
  domain_name       = "*.${var.site_domain_prefix}.${var.site_base_domain}"
  subject_alternative_names = ["${var.site_domain_prefix}.${var.site_base_domain}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "crc_resume_certificate_validation" {
  certificate_arn         = aws_acm_certificate.crc_resume_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.crc_resume_validation_records : record.fqdn]
}

# This code is straight out of the Terraform documentation for ACM DNS validation.
resource "aws_route53_record" "crc_resume_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.crc_resume_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.crc_resume_zone.zone_id
}