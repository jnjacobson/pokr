defmodule PokrWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> _game_id, _params, socket) do
    # generate user id
    socket = assign(socket, :id, UUID.uuid5(:nil, inspect(socket.transport_pid)))

    send(self(), :after_join)

    {:ok, socket}
  end

  def terminate(_reason, socket) do
    broadcast!(socket, "player_left", %{"id" => socket.assigns[:id]})

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "join", %{"player_id" => socket.assigns[:id], "are_cards_revealed" => false, "deck" => ~w(1 2 3 5 8 13 21 34 55 89 ?)})

    broadcast!(socket, "player_joined", %{})

    {:noreply, socket}
  end

  def handle_in("player_joined", _params, socket) do
    {:noreply, socket}
  end

  def handle_in("player_updated", params, socket) do
    broadcast!(socket, "player_updated", params)

    {:noreply, socket}
  end

  def handle_in("cards_revealed", params, socket) do
    broadcast!(socket, "cards_revealed", params)

    {:noreply, socket}
  end

  def handle_in("cards_reset", params, socket) do
    broadcast!(socket, "cards_reset", params)

    {:noreply, socket}
  end
end
