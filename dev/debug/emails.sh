#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

user_token=$SCRIPT_DIR/../oauth/oauth-user-token.json

USER_ACCESS_TOKEN=`jq -r '.access_token' $user_token`
echo "User access_token: $USER_ACCESS_TOKEN"

# Email endpoints
echo "Get surf/emails/confirmation"
curl -s -X GET "http://mastodon.local/api/v1/surf/emails/confirmation" -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .

echo "Get surf/emails/welcome"
curl -s -X GET "http://mastodon.local/api/v1/surf/emails/welcome" -H "Authorization: Bearer $USER_ACCESS_TOKEN" | jq .