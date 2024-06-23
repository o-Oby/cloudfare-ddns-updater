#!/bin/bash

# Function to read JSON values
get_json_value() {
  echo $(jq -r "$1" "$2")
}

# Configuration file
CONFIG_FILE="config.json"

# Read configuration
API_TOKEN=$(get_json_value '.API_TOKEN' "$CONFIG_FILE")
ZONE_ID=$(get_json_value '.ZONE_ID' "$CONFIG_FILE")
DNS_RECORD_NAME=$(get_json_value '.DNS_RECORD_NAME' "$CONFIG_FILE")
CF_API_URL=$(get_json_value '.CF_API_URL' "$CONFIG_FILE")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the current public IP address
echo -e "${CYAN}Checking current public IP address...${NC}"
CURRENT_IP=$(curl -s https://api.ipify.org)
echo -e "${GREEN}Current public IP: $CURRENT_IP${NC}"

# Get the DNS record details
echo -e "${CYAN}Retrieving DNS record details from Cloudflare...${NC}"
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
    echo -e "${YELLOW}IP address has changed from $OLD_IP to $CURRENT_IP. Updating DNS record...${NC}"
    UPDATE=$(curl -s -X PUT "$CF_API_URL/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$DNS_RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":true}")

    if echo $UPDATE | jq -e '.success' > /dev/null; then
      echo -e "${GREEN}DNS record updated successfully.${NC}"
    else
      echo -e "${RED}Failed to update DNS record: $UPDATE${NC}"
    fi
  else
    echo -e "${GREEN}IP address has not changed. No update needed.${NC}"
  fi
else
  echo -e "${RED}DNS record $DNS_RECORD_NAME not found.${NC}"
fi
