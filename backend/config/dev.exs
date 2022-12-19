import Config

# Configure your database
config :pokr, Pokr.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pokr_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :pokr, PokrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "6BWjSKJQJixgBRvcGpDQJlgjUvbKhCHtbTwnKltHo9mGZfDAxr+Wthqe0+91balz",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
