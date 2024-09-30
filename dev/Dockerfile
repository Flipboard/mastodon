# For details, see https://github.com/devcontainers/images/tree/main/src/ruby
FROM mcr.microsoft.com/devcontainers/ruby:1-3.2-bullseye

# Install Rails
# RUN gem install rails webdrivers

## Change when we merge main into release-42 branch
## ARG NODE_VERSION="20"

ARG NODE_VERSION="16"
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libicu-dev libidn11-dev ffmpeg imagemagick libpam-dev

# [Optional] Uncomment this line to install additional gems.
RUN gem install foreman

## Change when we merge main into release-42 branch
## RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && corepack enable" 2>&1
RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g yarn" 2>&1