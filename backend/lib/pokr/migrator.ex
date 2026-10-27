defmodule Pokr.Migrator do
  @moduledoc """
  Runs pending migrations while the application starts, before the endpoint
  accepts connections. The stack restarts Postgres together with the backend,
  so retry until the database answers.
  """

  require Logger

  @attempts 30

  def child_spec(_opts) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, []}, restart: :temporary}
  end

  def start_link do
    migrate(@attempts)
    :ignore
  end

  defp migrate(attempts) do
    Ecto.Migrator.run(Pokr.Repo, :up, all: true)
  rescue
    error in [DBConnection.ConnectionError, Postgrex.Error] ->
      if attempts > 1 do
        Logger.warning("Database not ready for migrations: " <> Exception.message(error))
        Process.sleep(1_000)
        migrate(attempts - 1)
      else
        reraise error, __STACKTRACE__
      end
  end
end
