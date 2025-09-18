#!/bin/bash

# Define credentials
USERNAME="voucher"
PASSWORD="creerdesvouchers"
SLACK_WEBHOOK="https://hooks.slack.com/services/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"
CURRENT_TIMESTAMP=$(($(date +%s) * 1000))

# Temporary cookie file
COOKIE_FILE=$(mktemp)

# Step 1: Perform login and store cookies
curl -s -c "$COOKIE_FILE" 'https://network.coworkinmontpellier.org:8443/api/login' \
  --data-raw "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"for_hotspot\":true,\"strict\":true,\"remember\":true,\"site_name\":\"default\"}" \
  -H 'Content-Type: application/json' > /dev/null 2>&1

# Step 3: Use the extracted cookie in another API call
CLIENTS=$(curl -s -b $COOKIE_FILE "https://network.coworkinmontpellier.org:8443/v2/api/site/default/hotspot/clients?withinHours=1");
GUESTS=$(curl -s -b $COOKIE_FILE 'https://network.coworkinmontpellier.org:8443/api/s/default/stat/guest?start=$CURRENT_TIMESTAMP&end=$CURRENT_TIMESTAMP');

# Step 4: Create a jq filter for MAC membership
# Prepare a jq array of guest MACs for use in the next filter
GUEST_MACS_JSON=$(echo "$GUESTS" | jq '[.data[] | select(.authorized_by == "voucher") | .mac]')
CLIENT_MACS_JSON=$(echo "$CLIENTS" | jq '[.[] | select(.authorized == true) | .mac] | map(select(. != null))')

# Step 5: Filter CLIENTS for authorized == true and mac in GUEST_MACS_JSON
AUTHORIZED_GUEST_DISPLAY_NAMES=$(echo "$CLIENTS" | jq --argjson guest_macs "$GUEST_MACS_JSON" '
  map(select(.authorized == true and (.mac as $m | $guest_macs | index($m))))
  | .[].display_name'
)
# Step 6: Filter GUESTS for authorized_by == "voucher" and mac in CLIENT_MACS_JSON
AUTHORIZED_CLIENTS_NAMES=$(echo "$GUESTS" | jq --argjson client_macs "$CLIENT_MACS_JSON" '
  .data | map(select(.authorized_by == "voucher" and (.mac as $m | $client_macs | index($m))))
  | .[].name'
)

NB_CONNECTED_GUESTS=$(echo "$AUTHORIZED_GUEST_DISPLAY_NAMES" | wc -l)
NB_CONNECTED_CLIENTS=$(echo "$AUTHORIZED_CLIENTS_NAMES" | wc -l)

echo "There are currently $NB_CONNECTED_GUESTS guests connected:"
echo "$AUTHORIZED_GUEST_DISPLAY_NAMES"
echo ""
echo "There are currently $NB_CONNECTED_CLIENTS clients connected:"
echo "$AUTHORIZED_CLIENTS_NAMES"
echo ""

JSON_MSG='{"text":"Salut Coworker! \n\nIl y a actuellement '$NB_CONNECTED_CLIENTS' coworkers connectés."}'

curl -X POST -H 'Content-type: application/json' --data "$JSON_MSG" $SLACK_WEBHOOK

# Clean up
rm "$COOKIE_FILE"
