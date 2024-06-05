# Developer Setup w/ Docker

- Install docker/docker-compose
- Edit `/etc/hosts` and add `127.0.0.1 mastodon.local`

# Running Apps

From the root of the repo run:

- `docker-compose -f dev/docker-compose.yml up`

The app takes a while to start. Patience, my friend.

## Hosts

The developer setup doesn't configure SSL and uses nginx as a reverse proxy (see: mastodon.local.conf).

- App:

  - `http://mastodon.local/`
  - `http://mastodon.local:3000/`
  - `http://127.0.0.1:3000/`

- Streaming:

  - `http://mastodon.local/api/v1/streaming`
  - `http://127.0.0.1:4000/api/v1/streaming`

- Email viewer: `http://mastodon.local/letter_opener`

# Data Directories

- `postgres14/` - nuke this directory if you want to start over
- `redis/` - stores the dump.rdb
