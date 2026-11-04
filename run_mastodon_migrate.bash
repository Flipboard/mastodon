#!/usr/bin/env bash
#
# Run Mastodon DB migrations for an upgrade, with the pre/post-deployment split.
# Run ONCE per pool's database, from that pool's shell box, as the mastodon user in ~/live.
# Usage: ./run_mastodon_migrate.bash <command>
#
# Zero-downtime major upgrade sequence:
#   1. snapshot the DB
#   2. ./run_mastodon_migrate.bash pre     # schema; safe while old code runs
#   3. deploy new code to all boxes + restart web/sidekiq/streaming
#   4. ./run_mastodon_migrate.bash post    # data migrations, after new code is live
#
# For test envs where brief downtime is fine, `all` does pre+post in one shot.
# ALWAYS run inside tmux — the concurrent unique index and account-dedup migrations
# can take a while and must not be interrupted.

set -uo pipefail

cd "$(dirname "$0")" 2>/dev/null || true
[ -f config/application.rb ] || { echo "✗ run this from the Mastodon app dir (e.g. ~/live)"; exit 1; }
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
export RAILS_ENV=production
RAILS="bundle exec rails"

usage() {
    echo "Usage: ./run_mastodon_migrate.bash <command>"
    echo ""
    echo "Commands:"
    echo "  pending   List migrations that haven't run yet"
    echo "  status    Show migrate status + current schema version"
    echo "  pre       Pre-deployment migrations (SKIP_POST_DEPLOYMENT_MIGRATIONS=true) — run BEFORE restart"
    echo "  post      Post-deployment migrations — run AFTER new code is deployed + restarted"
    echo "  all       pre + post together (test envs / brief-downtime OK)"
    echo ""
    echo "Sequence: snapshot DB -> pre -> deploy+restart all boxes -> post."
    echo "Run inside tmux; run ONCE per pool's database."
    exit 1
}

db_host() { grep -m1 -E '^DB_HOST=' .env.production 2>/dev/null | cut -d= -f2; }

preflight() {
    echo "DB_HOST : $(db_host)"
    echo "schema  : $($RAILS runner 'print ActiveRecord::Migrator.current_version' 2>/dev/null)"
    [ -n "${TMUX:-}" ] || echo "⚠  You are NOT in tmux — a disconnect could interrupt a long migration."
    echo -n "Snapshotted this DB and ready to migrate it? [type 'yes'] "
    read -r ans
    [ "$ans" = "yes" ] || { echo "aborted."; exit 1; }
}

case "${1:-}" in
    pending)
        $RAILS db:migrate:status | grep -E '^[[:space:]]+down' || echo "no pending migrations"
        ;;
    status)
        $RAILS db:migrate:status | tail -25
        $RAILS runner 'puts "schema version: #{ActiveRecord::Migrator.current_version}"'
        ;;
    pre)
        preflight
        SKIP_POST_DEPLOYMENT_MIGRATIONS=true $RAILS db:migrate
        echo "✓ pre-deployment migrations done. Now deploy+restart all boxes, then: ./run_mastodon_migrate.bash post"
        ;;
    post)
        preflight
        $RAILS db:migrate
        echo "✓ post-deployment migrations done. Verify: ./run_mastodon_migrate.bash status"
        ;;
    all)
        preflight
        $RAILS db:migrate
        echo "✓ all migrations done. Verify: ./run_mastodon_migrate.bash status"
        ;;
    *)
        usage
        ;;
esac
