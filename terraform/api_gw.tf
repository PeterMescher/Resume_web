resource "aws_apigatewayv2_api" "crc_website_counter_api" {
  name          = "crc_website_counter_api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["${var.site_domain_prefix}.${var.site_base_domain}"]
    allow_methods = ["GET"]
    max_age = 0
  }
  ip_address_type = "dualstack"
}

resource "aws_apigatewayv2_integration" "crc_website_counter_integration" {
  api_id             = aws_apigatewayv2_api.crc_website_counter_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.crc_website_counter_function.arn}/invocations"
}

resource "aws_apigatewayv2_route" "crc_website_counter_route" {
  api_id    = aws_apigatewayv2_api.crc_website_counter_api.id
  route_key = "GET /website_counter"
  target    = "integrations/${aws_apigatewayv2_integration.crc_website_counter_integration.id}"
}

resource "aws_apigatewayv2_stage" "crc_website_counter_stage" {
  api_id = aws_apigatewayv2_api.crc_website_counter_api.id
  name   = "$default"
  auto_deploy = true

  depends_on = [
    aws_apigatewayv2_route.crc_website_counter_route,
  ]
}

resource "aws_apigatewayv2_domain_name" "crc_website_counter_domain" {
  domain_name = "api.${var.site_domain_prefix}.${var.site_base_domain}"
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.crc_resume_certificate.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "crc_website_counter_api_mapping" {
  api_id      = aws_apigatewayv2_api.crc_website_counter_api.id
  domain_name = aws_apigatewayv2_domain_name.crc_website_counter_domain.domain_name
  stage       = aws_apigatewayv2_stage.crc_website_counter_stage.name
}

resource "aws_apigatewayv2_deployment" "crc_website_counter_deployment" {
  api_id = aws_apigatewayv2_api.crc_website_counter_api.id
  depends_on = [
    aws_apigatewayv2_route.crc_website_counter_route,
    aws_apigatewayv2_stage.crc_website_counter_stage,
  ]
}