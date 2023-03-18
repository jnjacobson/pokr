defmodule PokrWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, _params, socket) do
    Pokr.GameState.create_game(game_id)
    Pokr.GameState.increment_player_count(game_id)

    socket = assign(socket, :game_id, game_id)

    send(self(), :after_join)

    {:ok, socket}
  end

  def terminate(_reason, socket) do
    Pokr.GameState.decrement_player_count(socket.assigns[:game_id])

    if Pokr.GameState.has_players?(socket.assigns[:game_id]) do
      broadcast!(socket, "player_left", %{id: socket.assigns[:id]})
    else
      Pokr.GameState.delete_game(socket.assigns[:game_id])
    end

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "join", %{
      player_id: socket.assigns[:id],
      are_cards_revealed: Pokr.GameState.get_are_cards_revealed?(socket.assigns[:game_id]),
      deck: Pokr.GameState.get_deck(socket.assigns[:game_id])
    })

    broadcast!(socket, "player_joined", %{id: socket.assigns[:id]})

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
    Pokr.GameState.set_are_cards_revealed(socket.assigns[:game_id], true)

    broadcast!(socket, "cards_revealed", params)

    {:noreply, socket}
  end

  def handle_in("cards_reset", params, socket) do
    Pokr.GameState.set_are_cards_revealed(socket.assigns[:game_id], false)

    broadcast!(socket, "cards_reset", params)

    {:noreply, socket}
  end
end
