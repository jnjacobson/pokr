defmodule Pokr.GameCleaner do
  @moduledoc "Deletes games without activity once an hour."

  use GenServer

  require Logger

  @interval :timer.hours(1)

  def start_link(_opts), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @impl true
  def init(nil) do
    Process.send_after(self(), :clean, :timer.minutes(1))
    {:ok, nil}
  end

  @impl true
  def handle_info(:clean, state) do
    with {:ok, count} when count > 0 <- Pokr.Games.delete_stale_games() do
      Logger.info("Deleted #{count} stale games")
    end

    Process.send_after(self(), :clean, @interval)
    {:noreply, state}
  end
end
