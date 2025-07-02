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

# Gosh durn it, apigatewayv2 does not expose the hosted zone ID for the endpoint, so I have to
# extract it from the CLI Command for the API Gateway V2 domain name command.
# (I could build a table of the hosted zone IDs by region manually, but I'd hate to get caught off-guard if they change.)

# Using the CLI for this is explictly called for by the AWS API docs, as of Jul 2025:
# https://docs.aws.amazon.com/Route53/latest/APIReference/API_AliasTarget.html

data "external" "website_counter_apigwv2_domain_info" {
  program = ["bash", "${path.module}/get_apigw_domain.sh"]
  query = {
    domain_name = aws_apigatewayv2_domain_name.crc_website_counter_domain.domain_name
    region      = var.aws_region
    aws_profile = var.aws_profile
  }

  depends_on = [ aws_apigatewayv2_domain_name.crc_website_counter_domain ]
}


resource "aws_route53_record" "crc_website_counter_api_A_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "api.${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "A"

  alias {
    name                   = data.external.website_counter_apigwv2_domain_info.result["target_domain_name"]
    zone_id                = data.external.website_counter_apigwv2_domain_info.result["hosted_zone_id"]
    evaluate_target_health = true
  }
  
}

resource "aws_route53_record" "crc_website_counter_api_AAAA_record" {
  zone_id = aws_route53_zone.crc_resume_zone.zone_id
  name    = "api.${var.site_domain_prefix}.${var.site_base_domain}"
  type    = "AAAA"

  alias {
    name                   = data.external.website_counter_apigwv2_domain_info.result["target_domain_name"]
    zone_id                = data.external.website_counter_apigwv2_domain_info.result["hosted_zone_id"]
    evaluate_target_health = true
  }
  
}