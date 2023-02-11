# Extend from the official Elixir image.
FROM elixir:1.12-alpine

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

RUN rm -rf _build
RUN rm -rf deps

# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
RUN mix local.hex --force

RUN source .env
RUN mix deps.get --only prod
RUN mix local.rebar
RUN MIX_ENV=prod mix compile --force

CMD source .env && env MIX_ENV=prod mix phx.server
