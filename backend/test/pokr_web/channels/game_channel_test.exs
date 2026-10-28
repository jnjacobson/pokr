defmodule PokrWeb.GameChannelTest do
  use PokrWeb.ChannelCase

  alias Pokr.Games

  @deck ~w(S M L ? ☕)

  setup do
    {:ok, game} = Games.create_game(@deck)
    {:ok, game_id: game.id}
  end

  defp join_as(player_id, game_id) do
    {:ok, _, socket} =
      PokrWeb.Socket
      |> socket("socket:#{player_id}", %{id: player_id})
      |> subscribe_and_join(PokrWeb.GameChannel, "game:" <> game_id)

    socket
  end

  test "joining pushes presence, a signed token and the game state", %{game_id: game_id} do
    join_as("p1", game_id)

    assert_push "presence_state", %{"p1" => _}

    assert_push "join", %{
      player_id: "p1",
      token: token,
      are_cards_revealed: false,
      deck: deck
    }

    assert {:ok, "p1"} = Phoenix.Token.verify(PokrWeb.Endpoint, "player-token-salt", token)
    assert deck == @deck
  end

  test "a second player joins the same game and sees its state", %{game_id: game_id} do
    join_as("p1", game_id)
    assert_push "join", %{are_cards_revealed: false}

    Games.set_are_cards_revealed(game_id, true)

    join_as("p2", game_id)
    assert_push "join", %{player_id: "p2", are_cards_revealed: true}
  end

  test "player_updated is broadcast to the other players", %{game_id: game_id} do
    socket = join_as("p1", game_id)
    join_as("p2", game_id)

    push(socket, "player_updated", %{"id" => "p1", "name" => "Alice", "card" => "5"})

    assert_broadcast "player_updated", %{"id" => "p1", "name" => "Alice", "card" => "5"}
  end

  test "revealing and resetting cards is stored and broadcast", %{game_id: game_id} do
    socket = join_as("p1", game_id)

    push(socket, "cards_revealed", %{})
    assert_broadcast "cards_revealed", %{}
    assert Games.get_game(game_id).are_cards_revealed

    push(socket, "cards_reset", %{})
    assert_broadcast "cards_reset", %{}
    refute Games.get_game(game_id).are_cards_revealed
  end

  test "changing the deck is stored and broadcast", %{game_id: game_id} do
    socket = join_as("p1", game_id)

    push(socket, "deck_changed", %{"deck" => ~w(XS S M)})

    assert_broadcast "deck_changed", %{deck: ~w(XS S M)}
    assert Games.get_game(game_id).deck == ~w(XS S M)
  end

  test "an invalid deck is refused and not broadcast", %{game_id: game_id} do
    socket = join_as("p1", game_id)

    ref = push(socket, "deck_changed", %{"deck" => ~w(1 1)})

    assert_reply ref, :error, %{reason: :invalid_deck}
    refute_broadcast "deck_changed", _
    assert Games.get_game(game_id).deck == @deck
  end

  test "a deck change without a deck is refused", %{game_id: game_id} do
    socket = join_as("p1", game_id)

    ref = push(socket, "deck_changed", %{})

    assert_reply ref, :error, %{reason: :invalid_deck}
  end

  test "the deck cannot change while the cards are revealed", %{game_id: game_id} do
    socket = join_as("p1", game_id)
    push(socket, "cards_revealed", %{})
    assert_broadcast "cards_revealed", %{}

    ref = push(socket, "deck_changed", %{"deck" => ~w(XS S M)})

    assert_reply ref, :error, %{reason: :cards_revealed}
    refute_broadcast "deck_changed", _
    assert Games.get_game(game_id).deck == @deck
  end

  test "joining twice with the same player id announces a replaced session", %{game_id: game_id} do
    join_as("p1", game_id)
    assert_push "join", %{player_id: "p1"}

    join_as("p1", game_id)

    assert_broadcast "session_replaced", %{player_id: "p1", new_join_at: _}
  end

  test "a game survives its last player leaving", %{game_id: game_id} do
    socket = join_as("p1", game_id)
    push(socket, "cards_revealed", %{})
    assert_broadcast "cards_revealed", %{}

    close_and_wait(socket)

    join_as("p2", game_id)
    assert_push "join", %{player_id: "p2", are_cards_revealed: true}
  end

  test "joining a game that was never created is refused" do
    assert {:error, %{reason: :game_not_found}} =
             PokrWeb.Socket
             |> socket("socket:p1", %{id: "p1"})
             |> subscribe_and_join(PokrWeb.GameChannel, "game:sdfg")

    refute Games.get_game("sdfg")
  end

  defp close_and_wait(socket) do
    Process.unlink(socket.channel_pid)
    ref = Process.monitor(socket.channel_pid)
    close(socket)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end
