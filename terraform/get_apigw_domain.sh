#!/bin/bash

# This script retrieves the API Gateway zone ID and target domain name for a given API Gateway domain.
# It is intended to be used in a Terraform `external` data source.

# note: I'm not a bash expert, and I know this looks ugly, but the "clean" version suggested by chatGPT relies on
# jq, which is not part of a standard Linux install; this one is just bash (also written by chatGPT)

set -e

input=$(cat)

# Extract inputs
domain_name=$(echo "$input" | sed -n 's/.*"domain_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
region=$(echo "$input" | sed -n 's/.*"region"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
aws_profile=$(echo "$input" | sed -n 's/.*"aws_profile"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# Validate inputs
if [[ -z "$domain_name" || -z "$region" || -z "$aws_profile" ]]; then
  echo "Error: Missing domain_name, region, or aws_profile" >&2
  exit 1
fi

# Retry loop parameters
max_attempts=10
attempt=1
sleep_seconds=5

while [ $attempt -le $max_attempts ]; do
  response=$(aws apigatewayv2 get-domain-names --region "$region" --profile "$aws_profile" 2>/dev/null)

  # Extract the block for our domain
  block=$(echo "$response" | awk "/\"DomainName\": \"$domain_name\"/,/}/")

  # Extract values
  hosted_zone_id=$(echo "$block" | grep '"HostedZoneId"' | sed -n 's/.*"HostedZoneId"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  target_domain_name=$(echo "$block" | grep '"ApiGatewayDomainName"' | sed -n 's/.*"ApiGatewayDomainName"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

  if [[ -n "$hosted_zone_id" && -n "$target_domain_name" ]]; then
    # Success
    printf "{\"hosted_zone_id\": \"$hosted_zone_id\", \"target_domain_name\": \"$target_domain_name\"}"
    exit 0
  fi

  echo "Waiting for API Gateway domain \"$domain_name\" to become available (attempt $attempt/$max_attempts)..." >&2
  attempt=$((attempt + 1))
  sleep "$sleep_seconds"
done

echo "Error: Domain \"$domain_name\" not found after $((max_attempts * sleep_seconds)) seconds" >&2
exit 2
