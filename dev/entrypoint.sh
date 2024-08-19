#!/bin/bash

set -e # Fail the whole script on first error

# Fetch Ruby gem dependencies
bundle config path 'vendor/bundle'
bundle config with 'development'
bundle install

# Make Gemfile.lock pristine again
git checkout -- Gemfile.lock

# Fetch Javascript dependencies
# corepack prepare
yarn install

# You can comment these lines out if you need restart
# without needing to pickup new changes here...
# Run db setup/migrations
RAILS_ENV=development ./bin/rails db:setup
RAILS_ENV=development ./bin/rails db:migrate
# Generate public/assets
RAILS_ENV=development ./bin/rails assets:precompile

# This runs the Procfile.dev apps
foreman start