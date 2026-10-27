defmodule Pokr.GameStateTest do
  use ExUnit.Case

  alias Pokr.GameState

  setup do
    game_id = "test-" <> Integer.to_string(System.unique_integer([:positive]))
    on_exit(fn -> GameState.delete_game(game_id) end)
    {:ok, game_id: game_id}
  end

  test "creates a game once", %{game_id: game_id} do
    assert GameState.create_game(game_id) == :ok
    assert GameState.create_game(game_id) == :error
  end

  test "a new game has the default deck and hidden cards", %{game_id: game_id} do
    GameState.create_game(game_id)

    assert GameState.get_deck(game_id) == ~w(0 ½ 1 2 3 5 8 13 20 40 100 ? ☕)
    refute GameState.get_are_cards_revealed?(game_id)
  end

  test "toggles revealed cards", %{game_id: game_id} do
    GameState.create_game(game_id)

    GameState.set_are_cards_revealed(game_id, true)
    assert GameState.get_are_cards_revealed?(game_id)

    GameState.set_are_cards_revealed(game_id, false)
    refute GameState.get_are_cards_revealed?(game_id)
  end

  test "deleting a game allows creating it again", %{game_id: game_id} do
    GameState.create_game(game_id)
    assert GameState.delete_game(game_id) == :ok
    assert GameState.create_game(game_id) == :ok
  end

  test "a game without presences has no players", %{game_id: game_id} do
    refute GameState.has_players?(game_id)
  end
end
