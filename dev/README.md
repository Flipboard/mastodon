# Developer Setup w/ Docker

- Install docker/docker-compose

# Running Apps

Just use the default LOCAL_DOMAIN of `localhost:3000` for testing.

Before running the commands, you'll need to set the following environment variables if you want to test surf registrations:

- `SURF_REGISTRATIONS_ENABLED` - Whether surf registrations are enabled
- `SURF_REGISTRATION_TOKEN` - The registration token for the surf application. Doesn't matter for test environments but has to match when running the create-surf-user.sh script.

```
export SURF_REGISTRATIONS_ENABLED=true
export SURF_REGISTRATION_TOKEN=<SURF_REGISTRATION_TOKEN>
```

From the root of the repo run this commands to start the app:

- `docker compose -f .devcontainer/compose.yaml up`

Now open another terminal and run these commands:

- `docker compose -f .devcontainer/compose.yaml exec app bin/setup`
- `docker compose -f .devcontainer/compose.yaml exec app bin/dev`

And you'll need to stop the first terminal with `Ctrl+C` if you want to start over.

## Hosts

The developer setup doesn't configure SSL.

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
- `vendor/bundle` - stores the gems
- `public/{packs|packs-test|...}` - stores all the frontend assets

# Cleaning Dev Setup

- `docker compose -f .devcontainer/compose.yaml down`

# OAuth Client Testing

Create an oauth application and use it to test creating users or calling the api's.

Before running the scripts, you'll need to set the following environment variables:

- `SURF_REGISTRATION_TOKEN` - The registration token for the surf application

```
export SURF_REGISTRATION_TOKEN=<SURF_REGISTRATION_TOKEN>
```

Take a look at these files to ensure the api_host is set correctly for the environment you're testing:

```
./dev/oauth/create-client.sh
./dev/oauth/create-surf-user.sh
```

## Linting/Formatting

With the devcontainer docker compose file running, you can run the following commands to lint/format the code:

```
docker compose -f .devcontainer/compose.yaml exec app yarn format:check
docker compose -f .devcontainer/compose.yaml exec app yarn format
docker compose -f .devcontainer/compose.yaml exec app yarn format:check
docker compose -f .devcontainer/compose.yaml exec app yarn fix
```
