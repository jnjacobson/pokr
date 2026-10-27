defmodule PokrWeb.GameChannelTest do
  use PokrWeb.ChannelCase

  alias Pokr.GameState

  setup do
    game_id = unique_game_id()
    on_exit(fn -> GameState.delete_game(game_id) end)
    {:ok, game_id: game_id}
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
    assert deck == ~w(0 ½ 1 2 3 5 8 13 20 40 100 ? ☕)
  end

  test "joining creates the game, a second join reuses it", %{game_id: game_id} do
    join_as("p1", game_id)
    assert_push "join", %{are_cards_revealed: false}

    GameState.set_are_cards_revealed(game_id, true)

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
    assert GameState.get_are_cards_revealed?(game_id)

    push(socket, "cards_reset", %{})
    assert_broadcast "cards_reset", %{}
    refute GameState.get_are_cards_revealed?(game_id)
  end

  test "joining twice with the same player id announces a replaced session", %{game_id: game_id} do
    join_as("p1", game_id)
    assert_push "join", %{player_id: "p1"}

    join_as("p1", game_id)

    assert_broadcast "session_replaced", %{player_id: "p1", new_join_at: _}
  end

  describe "leaving" do
    # terminate/2 runs before the presence tracker notices the dead channel
    # process, so the game used to outlive its last player.
    test "the game is deleted once the last player leaves", %{game_id: game_id} do
      socket = join_as("p1", game_id)
      assert_push "join", %{}

      close_and_wait(socket)

      assert GameState.create_game(game_id) == :ok
    end

    test "the game is kept while another player is still in it", %{game_id: game_id} do
      socket = join_as("p1", game_id)
      join_as("p2", game_id)
      assert_push "join", %{player_id: "p2"}

      close_and_wait(socket)

      assert GameState.create_game(game_id) == :error
    end

    test "the game is kept when a replaced session of the same player closes", %{game_id: game_id} do
      old_socket = join_as("p1", game_id)
      join_as("p1", game_id)
      assert_push "join", %{player_id: "p1"}

      close_and_wait(old_socket)

      assert GameState.create_game(game_id) == :error
    end
  end

  defp close_and_wait(socket) do
    Process.unlink(socket.channel_pid)
    ref = Process.monitor(socket.channel_pid)
    close(socket)
    assert_receive {:DOWN, ^ref, _, _, _}
  end
end
