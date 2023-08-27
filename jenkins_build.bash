#!/usr/bin/env bash
#
# run as ubuntu

set -o errexit
set -o xtrace

if [[ $(whoami) != 'ubuntu' ]]; then
    echo 'This script must be run as ubuntu.'
    exit 1
fi

if [[ $# -eq 0 ]] ; then
    echo 'git commit hash must be passed as an argument'
    exit 1
fi

SRC_DIR="/mnt/jenkins-mastodon/workspace/${2}"
TARGET_DIR="/home/mastodon"
DATE=$(date +%Y%m%dT%H%M)
GIT_COMMIT="$1"

# save 1 level of backups
sudo rm -rfd "${TARGET_DIR}/"backup.*
sudo rm -rfd "${TARGET_DIR}/"*.tar.gz
sudo rm -rfd "${TARGET_DIR}/"updater_post_install.sh
sudo chmod -f 755 "${TARGET_DIR}"
if [[ -d "${TARGET_DIR}/live" ]] ; then
  sudo chmod -f 755 "${TARGET_DIR}/live"
  sudo mkdir "${TARGET_DIR}/backup.${DATE}"
  sudo mv "${TARGET_DIR}/live" "${TARGET_DIR}/backup.${DATE}/live"
fi

# copy over current code
sudo cp -r "${SRC_DIR}"/live "${TARGET_DIR}"

# get correct user
sudo chown -R mastodon:mastodon /home/mastodon

# build the code
#sudo -i -u mastodon bash --login -c 'cd live; export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; export RAILS_ENV=production; bundle config deployment "true"; bundle config without "development test"; bundle install; yarn install --pure-lockfile'

# tar and upload
sudo -i -u mastodon bash --login -c "cp live/updater_post_install.sh updater_post_install.sh; tar cvf ${GIT_COMMIT}.tar live updater_post_install.sh; gzip ${GIT_COMMIT}.tar; aws s3 cp ${GIT_COMMIT}.tar.gz s3://flipboard.prod.releases/mastodon/${GIT_COMMIT}.tar.gz"

exit 0

