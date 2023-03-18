FROM elixir:1.12-alpine AS base

# development
FROM base AS dev
ARG USER_ID
ARG GROUP_ID
RUN mkdir /.mix && chown $USER_ID:$GROUP_ID /.mix \
    && mkdir /.hex && chown $USER_ID:$GROUP_ID /.hex
USER $USER_ID:$GROUP_ID
RUN mix local.hex --force && mix local.rebar
CMD mix deps.get && mix phx.server

# production
FROM base

COPY .. /app
WORKDIR /app

RUN rm -rf _build deps .env.dist .gitignore Makefile README.md

# install hex & rebar
RUN mix local.hex --force && mix local.rebar

RUN mix deps.get --only prod

RUN MIX_ENV=prod mix compile

CMD source .env && env MIX_ENV=prod mix phx.server
