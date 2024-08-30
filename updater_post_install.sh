#!/usr/bin/env bash
#
# run as ubuntu

set -o errexit
set -o xtrace

if [[ `whoami` != 'ubuntu' ]]; then
    echo "This script must be run as ubuntu."
    exit 1
fi

_HERE=$(cd $(dirname "$0"); pwd)
SRC_DIR="${_HERE}"
#SRC_DIR="/ebsa/mastodon/current"
TARGET_DIR="/home/mastodon"
DATE=$(date +%Y%m%dT%H%M)

# save 1 level of backups
sudo chmod -f 755 "${TARGET_DIR}"
sudo rm -rfd "${TARGET_DIR}/"backup.*
sudo mkdir "${TARGET_DIR}/backup.${DATE}"
if [[ -d "${TARGET_DIR}/live" ]] ; then
  sudo chmod -f 755 "${TARGET_DIR}/live"
  sudo mv "${TARGET_DIR}/live" "${TARGET_DIR}/backup.${DATE}/live"
fi

# copy over current data
sudo cp -r "${SRC_DIR}"/live "${TARGET_DIR}"

# get pool for s3 configs
mypool="$(grep ec2.pool /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
mycluster="$(grep ec2.cluster /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"

# copy over important configs
local_domain="$(grep mastodon.local_domain /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
single_user_mode="$(grep mastodon.single_user_mode /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
secret_key_base="$(grep mastodon.secret_key_base /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
otp_secret="$(grep mastodon.otp_secret /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
vapid_private_key="$(grep mastodon.vapid_private_key /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
vapid_public_key="$(grep mastodon.vapid_public_key /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
db_host="$(grep mastodon.db_host /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
db_port="$(grep mastodon.db_port /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
db_name="$(grep mastodon.db_name /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
db_user="$(grep mastodon.db_user /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
db_pass="$(grep mastodon.db_pass /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
redis_host="$(grep mastodon.redis_host /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
redis_port="$(grep mastodon.redis_port /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
cache_redis_host="$(grep mastodon.cache_redis_host /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
cache_redis_port="$(grep mastodon.cache_redis_port /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
smtp_server="$(grep mastodon.smtp_server /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
smtp_port="$(grep mastodon.smtp_port /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
smtp_login="$(grep mastodon.smtp_login /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
smtp_password="$(grep mastodon.smtp_password /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
smtp_from_address="$(grep mastodon.smtp_from_address /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
es_enabled="$(grep mastodon.es_enabled /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
es_host="$(grep mastodon.es_host /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
es_port="$(grep mastodon.es_port /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
es_user="$(grep mastodon.es_user /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
es_pass="$(grep mastodon.es_pass /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
elastic_password="$(grep mastodon.elastic_password /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
elastic_security="$(grep mastodon.elastic_security /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
hcaptcha_sitekey="$(grep hcaptcha.site_key /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
hcaptcha_secret="$(grep hcaptcha.secret /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
deepl_key="$(grep mastodon.deepl_key /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"
deepl_plan="$(grep mastodon.deepl_plan /ebsa/config/services.config | cut -d '=' -f 2 | head -1)"

echo "# generated by internal build script on $(date)" > /tmp/env.production
echo "#" >> /tmp/env.production
echo "LOCAL_DOMAIN=${local_domain}" >> /tmp/env.production
echo "SINGLE_USER_MODE=${single_user_mode}" >> /tmp/env.production
echo "SECRET_KEY_BASE=${secret_key_base}" >> /tmp/env.production
echo "OTP_SECRET=${otp_secret}" >> /tmp/env.production
echo "VAPID_PRIVATE_KEY=${vapid_private_key}" >> /tmp/env.production
echo "VAPID_PUBLIC_KEY=${vapid_public_key}" >> /tmp/env.production
echo "DB_HOST=${db_host}" >> /tmp/env.production
echo "DB_PORT=${db_port}" >> /tmp/env.production
echo "DB_NAME=${db_name}" >> /tmp/env.production
echo "DB_USER=${db_user}" >> /tmp/env.production
echo "DB_PASS=${db_pass}" >> /tmp/env.production
echo "REDIS_HOST=${redis_host}" >> /tmp/env.production
echo "REDIS_PORT=${redis_port}" >> /tmp/env.production
echo "CACHE_REDIS_HOST=${cache_redis_host}" >> /tmp/env.production
echo "CACHE_REDIS_PORT=${cache_redis_port}" >> /tmp/env.production
echo "SMTP_SERVER=${smtp_server}" >> /tmp/env.production
echo "SMTP_PORT=${smtp_port}" >> /tmp/env.production
echo "SMTP_LOGIN=${smtp_login}" >> /tmp/env.production
echo "SMTP_PASSWORD=${smtp_password}" >> /tmp/env.production
echo "SMTP_FROM_ADDRESS=${smtp_from_address}" >> /tmp/env.production
echo "ES_ENABLED=${es_enabled}" >> /tmp/env.production
echo "ES_HOST=${es_host}" >> /tmp/env.production
echo "ES_PORT=${es_port}" >> /tmp/env.production
echo "ES_USER=${es_user}" >> /tmp/env.production
echo "ES_PASS=${es_pass}" >> /tmp/env.production
echo "ELASTIC_PASSWORD=${elastic_password}" >> /tmp/env.production
echo "ELASTIC_SECURITY=${elastic_security}" >> /tmp/env.production
echo "HCAPTCHA_SITE_KEY=${hcaptcha_sitekey}" >> /tmp/env.production
echo "HCAPTCHA_SECRET_KEY=${hcaptcha_secret}" >> /tmp/env.production
echo "DEEPL_API_KEY=${deepl_key}" >> /tmp/env.production
echo "DEEPL_PLAN=${deepl_plan}" >> /tmp/env.production
echo "S3_ENABLED=true" >> /tmp/env.production
echo "S3_REGION=us-east-1" >> /tmp/env.production
echo "S3_PROTOCOL=https" >> /tmp/env.production
echo "S3_HOSTNAME=s3-us-east-1.amazonaws.com" >> /tmp/env.production
if [[ "${mypool}" == "production" ]] ; then
  if [[ "${mycluster}" == "surf" ]] ; then
    echo "S3_BUCKET=m-cdn.surf.social" >> /tmp/env.production
    echo "S3_ALIAS_HOST=m-cdn.surf.social" >> /tmp/env.production
  else
    echo "S3_BUCKET=m-cdn.flipboard.social" >> /tmp/env.production
    echo "S3_ALIAS_HOST=m-cdn.flipboard.social" >> /tmp/env.production
  fi
elif [[ "${mypool}" == "beta" ]] ; then
  echo "S3_BUCKET=social-beta-cdn.flipboard.com" >> /tmp/env.production
  echo "S3_ALIAS_HOST=social-beta-cdn.flipboard.com" >> /tmp/env.production
else
  echo "S3_BUCKET=social-cdn.flipboard.com" >> /tmp/env.production
  echo "S3_ALIAS_HOST=social-cdn.flipboard.com" >> /tmp/env.production
fi
echo "STATSD_ADDR=localhost:8125" >> /tmp/env.production
echo "MAX_FOLLOWS_THRESHOLD=750_000" >> /tmp/env.production
echo "DISABLE_AUTOMATIC_SWITCHING_TO_APPROVED_REGISTRATIONS=true" >> /tmp/env.production
echo "TRUSTED_PROXY_IP=172.30.0.0/16,127.0.0.1/32" >> /tmp/env.production
echo "S3_RETRY_LIMIT=2" >> /tmp/env.production
echo "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=LP1Z5GeCrwZ1Q0hR9fWMbdYasm65QpfW" >> /tmp/env.production
echo "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=LsILEDcCPu74Yld55uSYoPpTII4UJTY7" >> /tmp/env.production
echo "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=XVLeQ3OpSTkrphXF9P2m0k8tJBBTz6fm" >> /tmp/env.production

# MASTODON_USE_LIBVIPS=true

sudo mv "/tmp/env.production" "${TARGET_DIR}/live/.env.production"

# get correct user
sudo chown -R mastodon:mastodon /home/mastodon

# build the code
sudo -i -u mastodon bash --login -c 'cd live; export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; export RAILS_ENV=production; bundle config deployment "true"; bundle config without "development test"; bundle install; yarn install --immutable'

# generate assets
sudo -i -u mastodon bash --login -c 'cd live; export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; RAILS_ENV=production bundle exec rails assets:precompile'

exit 0
