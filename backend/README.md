# Pokr Backend

Phoenix 1.8 (Elixir 1.20) API and websocket for pokr. Game state lives in memory (`lib/pokr/game_state.ex`); Postgres is part of the stack.

## Development

Usually started through `docker compose up` in the repo root (`mix phx.server` on `:4000`, Postgres host `postgres`).

## Configuration

Production needs these env vars: `PHX_HOST`, `PHX_CHECK_ORIGIN`, `SECRET_KEY_BASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_HOSTNAME`, `DB_DATABASE`, optional `DB_POOL_SIZE`.

On the server they come from the `environment:` block of the `pokr-backend` stack in Portainer, which is the only place the live values exist. The image contains no `.env`; the stack supplies everything. `.env.dist` only lists the names, with no real values; never commit a real `SECRET_KEY_BASE`.

To rotate `SECRET_KEY_BASE`: generate a value (`mix phx.gen.secret` or `openssl rand -hex 64`), paste it into the stack (Stacks -> pokr-backend -> Editor) and update the stack. No rebuild needed. This recreates the backend and Postgres containers (data stays in the `postgres-db` volume) and drops running games, since game state is in memory.

## Deployment

The server is an x86_64 Oracle Cloud VM; see the [root README](../README.md#infrastructure).

On every push to `main`, CI builds the image and pushes it to the public package `ghcr.io/jnjacobson/pokr-backend` (tags `latest` and the commit SHA). Only CI pushes there: the image is public, and `.dockerignore` keeps `.env` out of it. Never push a locally built image.

To deploy, open Stacks -> pokr-backend -> Editor in Portainer, enable "Re-pull image and redeploy" and click "Update the stack". The stack uses `ghcr.io/jnjacobson/pokr-backend:latest`; for a rollback, pin the image to an older commit SHA tag.
