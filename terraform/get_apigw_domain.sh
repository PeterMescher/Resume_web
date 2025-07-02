#!/bin/bash
set -e
domain_name=$(jq -r .domain_name)
region=$(jq -r .region)

aws apigatewayv2 get-domain-names --region "$region" \
  | jq -r --arg domain "$domain_name" '.Items[] | select(.DomainName == $domain) | {hosted_zone_id: .DomainNameConfigurations[0].HostedZoneId, target_domain_name: .DomainNameConfigurations[0].ApiGatewayDomainName}'
