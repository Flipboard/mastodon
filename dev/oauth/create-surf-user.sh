#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

app_client_token=$SCRIPT_DIR/oauth-client-token.json
user_token=$SCRIPT_DIR/oauth-user-token.json
user=$SCRIPT_DIR/oauth-user.json

USER_PASSWORD="ZXCzxcASDasdQWEqwe"

echo "Creating new user..."
APP_ACCESS_TOKEN=`jq -r '.access_token' $app_client_token`

TIME=`date +%s`
curl -s -X POST http://mastodon.local/api/v1/surf/accounts \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" \
  -d "{\"username\": \"test_$TIME\", \"email\": \"test-$TIME@mastodon.local\", \"password\": \"$USER_PASSWORD\", \"agreement\": true, \"locale\": \"en\"}" > $user_token

echo "Reading $user_token"
cat $user_token | jq .

# get user access token
USER_ACCESS_TOKEN=`jq -r '.access_token' $user_token`

echo "Get user details..."
curl -s -X GET "http://mastodon.local/api/v1/surf/users/whoami" -H "Authorization: Bearer $USER_ACCESS_TOKEN" > $user
cat $user | jq .

echo "Confirm new user..."
CONFIRMATION_TOKEN=`jq -r '.confirmation_token' $user`
curl -s -X GET "http://mastodon.local/api/v1/surf/users/confirmation?confirmation_token=$CONFIRMATION_TOKEN" \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" | jq .

echo "Verify user credentials..."
curl -s -X GET "http://mastodon.local/api/v1/accounts/verify_credentials" -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .

echo "Sign out user..."
curl -s -X POST "http://mastodon.local/api/v1/surf/users/sign_out" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .

echo "Verify account credentials..."
curl -s -X GET "http://mastodon.local/api/v1/accounts/verify_credentials" -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .

echo "Sign in user..."
curl -s -X POST "http://mastodon.local/api/v1/surf/users/sign_in" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" \
  -d "{\"email\": \"test-$TIME@mastodon.local\", \"password\": \"$USER_PASSWORD\"}"  > $user_token
cat $user_token | jq .
