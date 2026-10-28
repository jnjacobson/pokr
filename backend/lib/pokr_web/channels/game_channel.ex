defmodule PokrWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> game_id, _params, socket) do
    case Pokr.Games.join_game(game_id) do
      {:ok, game} ->
        socket = assign(socket, :game_id, game_id)

        send(self(), {:after_join, game})

        {:ok, socket}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  def handle_info({:after_join, game}, socket) do
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

    {:ok, _} =
      PokrWeb.Presence.track(socket, player_id, %{
        online_at: join_timestamp
      })

    push(socket, "presence_state", PokrWeb.Presence.list(socket))

    push(socket, "join", %{
      player_id: player_id,
      token: Phoenix.Token.sign(PokrWeb.Endpoint, "player-token-salt", player_id),
      joined_at: join_timestamp,
      are_cards_revealed: game.are_cards_revealed,
      deck: game.deck
    })

    {:noreply, socket}
  end

  def handle_in("player_updated", params, socket) do
    broadcast!(socket, "player_updated", params)

    {:noreply, socket}
  end

  def handle_in("deck_changed", params, socket) do
    deck = params["deck"]

    case Pokr.Games.set_deck(socket.assigns[:game_id], deck) do
      :ok ->
        broadcast!(socket, "deck_changed", %{deck: deck})
        {:noreply, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  def handle_in("cards_revealed", params, socket) do
    case Pokr.Games.set_are_cards_revealed(socket.assigns[:game_id], true) do
      :ok ->
        broadcast!(socket, "cards_revealed", params)
        {:noreply, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  def handle_in("cards_reset", params, socket) do
    case Pokr.Games.set_are_cards_revealed(socket.assigns[:game_id], false) do
      :ok ->
        broadcast!(socket, "cards_reset", params)
        {:noreply, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end
end
