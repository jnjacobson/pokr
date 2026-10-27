defmodule Pokr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [Pokr.Repo] ++
        database_tasks([Pokr.Migrator]) ++
        [
          PokrWeb.Telemetry,
          {Phoenix.PubSub, name: Pokr.PubSub},
          PokrWeb.Endpoint,
          PokrWeb.Presence
        ] ++ database_tasks([Pokr.GameCleaner])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pokr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tests run the migrations through the `test` alias and own the sandbox.
  defp database_tasks(children) do
    if Application.get_env(:pokr, :run_database_tasks, true), do: children, else: []
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PokrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
