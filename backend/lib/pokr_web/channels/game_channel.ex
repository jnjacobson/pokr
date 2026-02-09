defmodule PokrWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, _params, socket) do
    Pokr.GameState.create_game(game_id)

    socket = assign(socket, :game_id, game_id)

    send(self(), :after_join)

    {:ok, socket}
  end

  def terminate(_reason, socket) do
    if !Pokr.GameState.has_players?(socket.assigns[:game_id]) do
      Pokr.GameState.delete_game(socket.assigns[:game_id])
    end

    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    presence_list = PokrWeb.Presence.list(socket)
    player_id = socket.assigns[:id]
    game_id = socket.assigns[:game_id]
    join_timestamp = System.system_time(:millisecond)

    if Map.has_key?(presence_list, player_id) do
      # Player joined twice, notify the other tab to close.
      PokrWeb.Endpoint.broadcast!("game:#{game_id}", "session_replaced", %{
        player_id: player_id,
        new_join_at: join_timestamp
      })
    end

    {:ok, _} = PokrWeb.Presence.track(socket, player_id, %{
      online_at: join_timestamp
    })

    push(socket, "presence_state", PokrWeb.Presence.list(socket))

    push(socket, "join", %{
      player_id: player_id,
      token: Phoenix.Token.sign(PokrWeb.Endpoint, "player-token-salt", player_id),
      joined_at: join_timestamp,
      are_cards_revealed: Pokr.GameState.get_are_cards_revealed?(game_id),
      deck: Pokr.GameState.get_deck(game_id)
    })

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
