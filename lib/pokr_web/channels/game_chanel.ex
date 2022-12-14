defmodule PokrWeb.GameChanel do
  use Phoenix.Channel

  def join("game:" <> _game_id, _params, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    broadcast!(socket, "player_joined", nil)

    {:noreply, socket}
  end

  def handle_in("player_updated", params, socket) do
    broadcast!(socket, "player_updated", params)

    {:noreply, socket}
  end

  def handle_in("cards_reset", params, socket) do
    broadcast!(socket, "cards_reset", params)

    {:noreply, socket}
  end

  def handle_in("cards_revealed", params, socket) do
    broadcast!(socket, "cards_revealed", params)

    {:noreply, socket}
  end
end
