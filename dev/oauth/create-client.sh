#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

app_client=$SCRIPT_DIR/oauth-client.json
app_client_token=$SCRIPT_DIR/oauth-client-token.json
app_scopes="read write follow push"

echo "Creating client application..."
curl -s -X POST \
	-F 'client_name=Test' \
	-F 'redirect_uris=urn:ietf:wg:oauth:2.0:oob' \
	-F "scopes=$app_scopes" \
	-F 'website=http://mastodon.local' \
	http://mastodon.local/api/v1/apps > $app_client

echo "Reading $app_client..."
cat $app_client | jq .

echo "Creating client access token for..."
CLIENT_ID=`jq -r '.client_id' $app_client`
CLIENT_SECRET=`jq -r '.client_secret' $app_client`
curl -s -X POST \
  -F "client_id=$CLIENT_ID" \
  -F "client_secret=$CLIENT_SECRET" \
  -F 'redirect_uri=urn:ietf:wg:oauth:2.0:oob' \
  -F "scope=$app_scopes" \
  -F 'grant_type=client_credentials' \
  http://mastodon.local/oauth/token > $app_client_token

echo "Reading $app_client_token..."
cat $app_client_token | jq .

echo "Verify app credentials..."
APP_ACCESS_TOKEN=`jq -r '.access_token' $app_client_token`
curl -s -X GET "http://mastodon.local/api/v1/apps/verify_credentials" \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" | jq .
