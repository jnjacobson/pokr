# Pokr Backend

Phoenix 1.8 (Elixir 1.20) API and websocket for pokr. Players and their cards live in the clients and in Phoenix Presence. The rest of a game's state (whether the cards are revealed) is stored in the `games` table (`lib/pokr/games.ex`), so it survives a restart. Games without activity for 7 days are deleted hourly.

## Development

Usually started through `docker compose up` in the repo root (`mix phx.server` on `:4000`, Postgres host `postgres`). Pending migrations run when the app starts, in dev and in production; `mix test` migrates the test database itself.

## Configuration

Production needs these env vars: `PHX_HOST`, `PHX_CHECK_ORIGIN`, `SECRET_KEY_BASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_HOSTNAME`, `DB_DATABASE`, optional `DB_POOL_SIZE`.

On the server they come from the `environment:` block of the `pokr-backend` stack in Portainer, which is the only place the live values exist. The image contains no `.env`; the stack supplies everything. `.env.dist` only lists the names, with no real values; never commit a real `SECRET_KEY_BASE`.

To rotate `SECRET_KEY_BASE`: generate a value (`mix phx.gen.secret` or `openssl rand -hex 64`), paste it into the stack (Stacks -> pokr-backend -> Editor) and update the stack. No rebuild needed. This restarts the backend and Postgres containers (data stays in the `postgres-db` volume). Clients reconnect on their own and keep their games.

## Deployment

The server is an x86_64 Oracle Cloud VM; see the [root README](../README.md#infrastructure).

When a push to `main` changes anything under `backend/`, CI builds the image (a Mix release started with `bin/server`, so the stack must not override the command) and pushes it to the public package `ghcr.io/jnjacobson/pokr-backend` (tags `latest` and the commit SHA). Only CI pushes there: the image is public, and `.dockerignore` keeps `.env` out of it. Never push a locally built image.

When a push to `main` changes anything under `backend/`, CI publishes the image and then the `deploy-backend` job redeploys the `pokr-backend` stack (image `ghcr.io/jnjacobson/pokr-backend:latest`) through the Portainer API: it sends back the stack's current file and env with a re-pull of the images. It needs the repository secret `PORTAINER_TOKEN`, a Portainer access token (My account -> Access tokens). Each deploy restarts the containers; clients reconnect and keep their games.

To deploy by hand, open Stacks -> pokr-backend -> Editor in Portainer, enable "Re-pull image and redeploy" and click "Update the stack". For a rollback, pin the stack's image to an older commit SHA tag.
