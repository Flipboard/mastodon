#!/usr/bin/env bash
#########################################################
# This script creates a new client application
# It will create a new client application and a new client access token
# and save them to the oauth-client.json and oauth-client-token.json files
#
# To run the script:
# ./create-client.sh
#########################################################
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

api_host="http://mastodon.local:3000"
# api_host="https://gumby.social"
client_name="Test client"

app_client=$SCRIPT_DIR/oauth-client.json
app_client_token=$SCRIPT_DIR/oauth-client-token.json
app_scopes="profile read write push admin:read admin:write"

#########################################################
# Create a new client application
#########################################################
echo "Creating client application..."
curl -s -X POST \
	-F "client_name=$client_name" \
	-F "redirect_uris=urn:ietf:wg:oauth:2.0:oob" \
	-F "scopes=$app_scopes" \
	-F "website=$api_host" \
	-L \
	$api_host/api/v1/apps > $app_client

echo "Reading $app_client..."
cat $app_client | jq .

#########################################################
# Create a new client access token
#########################################################
echo "Creating client access token for..."
CLIENT_ID=`jq -r '.client_id' $app_client`
CLIENT_SECRET=`jq -r '.client_secret' $app_client`
curl -s -X POST \
  -F "client_id=$CLIENT_ID" \
  -F "client_secret=$CLIENT_SECRET" \
  -F 'redirect_uri=urn:ietf:wg:oauth:2.0:oob' \
  -F "scope=$app_scopes" \
  -F 'grant_type=client_credentials' \
  $api_host/oauth/token > $app_client_token

echo "Reading $app_client_token..."
cat $app_client_token | jq .

echo "Verify app credentials..."
APP_ACCESS_TOKEN=`jq -r '.access_token' $app_client_token`
curl -s -X GET "$api_host/api/v1/apps/verify_credentials" \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" -L | jq .
