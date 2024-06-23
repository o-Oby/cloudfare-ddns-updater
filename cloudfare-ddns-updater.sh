#!/bin/bash

# Configuration
API_TOKEN='your_cloudflare_api_token'  # Replace with your actual API token
ZONE_ID='your_zone_id'  # Replace with your actual zone ID
DNS_RECORD_NAME='your_subdomain.example.com'  # Replace with your actual subdomain
IP_CHECK_URL='https://api.ipify.org'
CF_API_URL='https://api.cloudflare.com/client/v4'

# Get the current public IP address
CURRENT_IP=$(curl -s $IP_CHECK_URL)

# Get the DNS record details
DNS_RECORDS=$(curl -s -X GET "$CF_API_URL/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json")

# Find the specific DNS record
DNS_RECORD=$(echo $DNS_RECORDS | jq -r --arg name "$DNS_RECORD_NAME" '.result[] | select(.name == $name)')

if [ -n "$DNS_RECORD" ]; then
  DNS_RECORD_ID=$(echo $DNS_RECORD | jq -r '.id')
  OLD_IP=$(echo $DNS_RECORD | jq -r '.content')

  if [ "$OLD_IP" != "$CURRENT_IP" ]; then
    # Update the DNS record
    UPDATE=$(curl -s -X PUT "$CF_API_URL/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$DNS_RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":true}")

    echo "DNS record updated: $UPDATE"
  else
    echo "IP address has not changed."
  fi
else
  echo "DNS record $DNS_RECORD_NAME not found."
fi
