#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

app_client_token=$SCRIPT_DIR/oauth-client-token.json
user_token=$SCRIPT_DIR/oauth-user-token.json

echo "Creating new user..."
APP_ACCESS_TOKEN=`jq -r '.access_token' $app_client_token`
TIME=`date +%s`
curl -s -X POST http://mastodon.local/api/v1/surf/accounts \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" \
  -d "{\"username\": \"test_$TIME\", \"email\": \"test-$TIME@mastodon.local\", \"password\": \"ZXCzxcASDasdQWEqwe\", \"agreement\": true, \"locale\": \"en\"}" > $user_token

echo "Reading $user_token"
cat $user_token | jq .

echo "Verify user credentials..."
USER_ACCESS_TOKEN=`jq -r '.access_token' $user_token`
curl -s -X GET "http://mastodon.local/api/v1/accounts/verify_credentials" -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .

echo "Get user details..."
curl -s -X GET "http://mastodon.local/api/v1/surf/users/whoami" -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .
