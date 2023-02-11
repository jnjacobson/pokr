FROM elixir:1.12-alpine

COPY . /app
WORKDIR /app

RUN rm -rf _build deps

# install hex & rebar
RUN mix local.hex --force
RUN mix local.rebar

RUN mix deps.get --only prod

RUN MIX_ENV=prod mix compile

CMD source .env && env MIX_ENV=prod mix phx.server
