defmodule Pokr.GamesTest do
  use Pokr.DataCase

  alias Pokr.{Game, Games}

  setup do
    {:ok, game_id: "test-" <> Integer.to_string(System.unique_integer([:positive]))}
  end

  test "a new game has the default deck and hidden cards", %{game_id: game_id} do
    assert {:ok, game} = Games.join_game(game_id)

    assert game.deck == ~w(0 ½ 1 2 3 5 8 13 20 40 100 ? ☕)
    refute game.are_cards_revealed
  end

  test "joining an existing game keeps its state", %{game_id: game_id} do
    Games.join_game(game_id)
    Games.set_are_cards_revealed(game_id, true)

    assert {:ok, %Game{are_cards_revealed: true}} = Games.join_game(game_id)
    assert Repo.aggregate(Game, :count) == 1
  end

  test "toggles revealed cards", %{game_id: game_id} do
    Games.join_game(game_id)

    assert Games.set_are_cards_revealed(game_id, true) == :ok
    assert Games.get_game(game_id).are_cards_revealed

    assert Games.set_are_cards_revealed(game_id, false) == :ok
    refute Games.get_game(game_id).are_cards_revealed
  end

  test "revealing cards creates a game that was deleted meanwhile", %{game_id: game_id} do
    assert Games.set_are_cards_revealed(game_id, true) == :ok
    assert Games.get_game(game_id).are_cards_revealed
  end

  describe "delete_stale_games/0" do
    test "deletes games without activity for a week and keeps the others" do
      for {id, days} <- [{"active", 0}, {"recent", 6}, {"old", 8}] do
        Games.join_game(id)
        backdate(id, days)
      end

      assert Games.delete_stale_games() == {:ok, 1}

      assert Games.get_game("active")
      assert Games.get_game("recent")
      refute Games.get_game("old")
    end
  end

  defp backdate(game_id, days) do
    updated_at = DateTime.utc_now() |> DateTime.add(-days, :day) |> DateTime.truncate(:second)
    Repo.update_all(from(g in Game, where: g.id == ^game_id), set: [updated_at: updated_at])
  end
end
