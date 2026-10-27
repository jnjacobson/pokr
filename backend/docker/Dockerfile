FROM elixir:1.20-alpine AS base

# development
FROM base AS dev
ARG USER_ID
ARG GROUP_ID
RUN mkdir /.mix && chown $USER_ID:$GROUP_ID /.mix \
    && mkdir /.hex && chown $USER_ID:$GROUP_ID /.hex
USER $USER_ID:$GROUP_ID
RUN mix local.hex --force && mix local.rebar
CMD mix deps.get && mix phx.server

# production build
FROM base AS build

ENV MIX_ENV=prod
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config config
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY rel rel
RUN mix release

# production
FROM alpine:3.24

RUN apk add --no-cache libstdc++ ncurses-libs openssl

ENV LANG=C.UTF-8
WORKDIR /app
COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/pokr ./
USER nobody

CMD ["bin/server"]
