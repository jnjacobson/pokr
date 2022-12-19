import Config

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/pokr start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :pokr, PokrWeb.Endpoint, server: true
end

if config_env() == :prod do
  config :pokr, Pokr.Repo,
    # ssl: true,
    username: System.fetch_env!("DB_USERNAME"),
    password: System.fetch_env!("DB_PASSWORD"),
    hostname: System.fetch_env!("DB_HOSTNAME"),
    database: System.fetch_env!("DB_DATABASE"),
    pool_size: String.to_integer(System.get_env("DB_POOL_SIZE") || "10")

  config :pokr, PokrWeb.Endpoint,
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE"),
    url: [
      host: System.fetch_env!("PHX_HOST"),
      port: 443,
      scheme: "https"
    ],
    https: [
      port: 443,
      cipher_suite: :strong,
      keyfile: System.fetch_env!("SSL_KEY_PATH"),
      certfile: System.fetch_env!("SSL_CERT_PATH")
    ],
    force_ssl: [hsts: true]
end
