#!/usr/bin/env bash
#
# run as ubuntu

set -o errexit
set -o xtrace

if [[ `whoami` != 'ubuntu' ]]; then
    echo "This script must be run as ubuntu."
    exit 1
fi

SRC_DIR="/mnt/jenkins-mastodon/workspace/mastodon"
TARGET_DIR="/home/mastodon"
DATE=$(date +%Y%m%dT%H%M)

# save 1 level of backups
sudo rm -rfd "${TARGET_DIR}/"backup.*
sudo rm -rfd "${TARGET_DIR}/"*.tar.gz
sudo rm -rfd "${TARGET_DIR}/"updater_post_install.sh
if [[ -f ${TARGET_DIR}/live ]] ; then
  sudo mkdir "${TARGET_DIR}/backup.${DATE}"
  sudo mv "${TARGET_DIR}/live" "${TARGET_DIR}/backup.${DATE}/live"
fi

# copy over current code
sudo cp -r "${SRC_DIR}"/live "${TARGET_DIR}"

# get correct user
sudo chown -R mastodon:mastodon /home/mastodon

# build the code
sudo -i -u mastodon bash --login -c 'cd live; export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; export RAILS_ENV=production; bundle config deployment "true"; bundle config without "development test"; bundle install; yarn install --pure-lockfile'

exit 0

