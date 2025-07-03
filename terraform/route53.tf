resource "aws_route53_zone" "crc_resume_zone" {
  name = "${var.site_domain_prefix}.${var.site_base_domain}"
  comment = "Route 53 zone for ${var.site_domain_prefix}.${var.site_base_domain} managed by Terraform"
}

resource "aws_route53_record" "site_delegation_records" {

# This resource creates NS records in the root domain's Route 53 zone to delegate the subdomain to the new zone created above.
# The provider is set to the root domain account to ensure the delegation is done in the correct account.

  provider = aws.root_domain_acct

  zone_id = var.site_root_zone_id
  name    = "${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "NS"
  ttl     = 300

  records = aws_route53_zone.crc_resume_zone.name_servers
}

resource "aws_route53_record" "base_site_hosting_A_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.crc_resume_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.crc_resume_cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_site_hosting_A_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "www.${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.crc_resume_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.crc_resume_cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "base_site_hosting_AAAA_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.crc_resume_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.crc_resume_cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_site_hosting_AAAA_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "www.${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.crc_resume_cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.crc_resume_cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "crc_website_counter_api_A_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "api.${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.crc_website_counter_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.crc_website_counter_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = true
  }
  
}

resource "aws_route53_record" "crc_website_counter_api_AAAA_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "api.${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "AAAA"

  alias {
    name                   = aws_apigatewayv2_domain_name.crc_website_counter_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.crc_website_counter_domain.domain_name_configuration[0].hosted_zone_id
     evaluate_target_health = true
  }
  
}