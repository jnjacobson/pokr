defmodule Pokr.Repo do
  use Ecto.Repo,
    otp_app: :pokr,
    adapter: Ecto.Adapters.Postgres
end
