#!/usr/bin/env bash
#
# run as ubuntu

set -o errexit
set -o xtrace

if [[ `whoami` != 'ubuntu' ]]; then
    echo "This script must be run as ubuntu."
    exit 1
fi

SRC_DIR="/ebsa/mastodon/current"
TARGET_DIR="/home/mastodon"
DATE=$(date +%Y%m%dT%H%M)

# save 1 level of backups
sudo rm -rfd "${TARGET_DIR}/"backup.*
sudo mkdir "${TARGET_DIR}/backup.${DATE}"
sudo mv "${TARGET_DIR}/live" "${TARGET_DIR}/backup.${DATE}/live"

# copy over current data
sudo cp -r "${SRC_DIR}"/live "${TARGET_DIR}"

# copy over important configs
sudo cp "${TARGET_DIR}/.env.production" "${TARGET_DIR}/live/.env.production"

# get correct user
sudo chown -R mastodon:mastodon /home/mastodon

# generate assets
sudo -i -u mastodon bash --login -c 'cd live; export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; RAILS_ENV=production bundle exec rails assets:precompile'

exit 0
