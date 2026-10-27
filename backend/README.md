# Pokr Backend

Phoenix 1.6 (Elixir 1.12) API and websocket for pokr. Game state lives in memory (`lib/pokr/game_state.ex`); Postgres is part of the stack.

## Development

Usually started through `docker compose up` in the repo root (`mix phx.server` on `:4000`, Postgres host `postgres`).

## Configuration

Production needs these env vars: `PHX_HOST`, `PHX_CHECK_ORIGIN`, `SECRET_KEY_BASE`, `DB_USERNAME`, `DB_PASSWORD`, `DB_HOSTNAME`, `DB_DATABASE`, optional `DB_POOL_SIZE`.

On the server they come from the `environment:` block of the `pokr-backend` stack in Portainer, which is the only place the live values exist. The stack overrides the command with `mix phx.server`, so the `.env` that the image copies in at build time is **not** used in production. `.env.dist` only lists the names, with no real values; never commit a real `SECRET_KEY_BASE`.

To rotate `SECRET_KEY_BASE`: generate a value (`mix phx.gen.secret` or `openssl rand -hex 64`), paste it into the stack (Stacks -> pokr-backend -> Editor) and update the stack. No rebuild needed. This recreates the backend and Postgres containers (data stays in the `postgres-db` volume) and drops running games, since game state is in memory.

`DEPLOY_SSH_USER` / `DEPLOY_SSH_HOST` / `DEPLOY_TAR_PATH` are only used by the Makefile. Pass them on the command line, e.g. `make build-tar-remote DEPLOY_SSH_USER=ubuntu DEPLOY_SSH_HOST=<ip>`.

## Deployment

The server is an x86_64 Oracle Cloud VM; see the [root README](../README.md#infrastructure).

1. Run `make build-tar` or `make build-tar-remote` to build the Docker image tar. Use `build-tar-remote` on Apple Silicon: it builds on the server over SSH with buildx (`amd64builder`).
2. Run `make copy-tar` to copy the tar to the server and `docker load` it there.
3. In Portainer:
   - Restart the pokr-backend stack (Stacks -> pokr-backend -> Editor -> Update the stack)
   - Remove the old image (Images -> Remove the unused image)
