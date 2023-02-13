import Config

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
    http: [ip: {0, 0, 0, 0}, port: 4000],
    server: true
end
