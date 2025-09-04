#!/usr/bin/env bash
#########################################################
# This script creates a new user and requires running create-client.sh first
# to create an app access token.

# Run this script as is and if you want to test specific scenarios,
# keep in mind the email address using a timestamp to it might be hard to login
# if you only want to test the login functionality. You'll need to change the email address.

# To run the script:
# ./create-surf-user.sh
#########################################################
set -ex
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

api_host="http://mastodon.local:3000"
#api_host="https://gumby.social"
app_client_token=$SCRIPT_DIR/oauth-client-token.json
user_token=$SCRIPT_DIR/oauth-user-token.json
user=$SCRIPT_DIR/oauth-user.json

USER_PASSWORD="ZXCzxcASDasdQWEqwe"

## read app access token from file
APP_ACCESS_TOKEN=`jq -r '.access_token' $app_client_token`

## create a new user... X-Surf-Client-Id is required and must be FLDailyMastodon
## to pass the check_enabled_registrations check
echo "Creating new user..."
TIME=`date +%s`
curl -s -X POST $api_host/api/v1/surf/accounts \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" \
  -H "X-Surf-Client-Id: FLDailyMastodon" \
  -d "{\"username\": \"test_$TIME\", \"email\": \"test-$TIME@mastodon.local\", \"password\": \"$USER_PASSWORD\", \"agreement\": true, \"locale\": \"en\"}" -L > $user_token

echo "Reading $user_token"
cat $user_token | jq .

## read user access token from file
USER_ACCESS_TOKEN=`jq -r '.access_token' $user_token`

echo "Verify user credentials..."
curl -s -X GET "$api_host/api/v1/accounts/verify_credentials" -H "Authorization: Bearer $USER_ACCESS_TOKEN" -L | jq . > $user
cat $user | jq .

echo "Sign out user..."
curl -s -X POST "$api_host/api/v1/surf/users/sign_out" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $USER_ACCESS_TOKEN" -L| jq .

echo "Verify account credentials..."
curl -s -X GET "$api_host/api/v1/accounts/verify_credentials" -H "Authorization: Bearer $USER_ACCESS_TOKEN" -L | jq . > $user
cat $user | jq .

echo "Sign in user..."
curl -s -X POST "$api_host/api/v1/surf/users/sign_in" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $APP_ACCESS_TOKEN" \
  -d "{\"email\": \"test-$TIME@mastodon.local\", \"password\": \"$USER_PASSWORD\"}" -L > $user_token
cat $user_token | jq .

## read user access token from file
USER_ACCESS_TOKEN=`jq -r '.access_token' $user_token`
echo "Verify account credentials..."
curl -s -X GET "$api_host/api/v1/accounts/verify_credentials" -H "Authorization: Bearer $USER_ACCESS_TOKEN" -L | jq . > $user
cat $user | jq .