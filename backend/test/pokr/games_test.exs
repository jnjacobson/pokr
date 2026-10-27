defmodule Pokr.GamesTest do
  use Pokr.DataCase

  alias Pokr.{Game, Games}

  setup do
    {:ok, game} = Games.create_game()
    {:ok, game_id: game.id}
  end

  describe "create_game/0" do
    test "creates a game with a three word slug, the default deck and hidden cards", %{
      game_id: game_id
    } do
      assert game_id =~ ~r/^[a-z]+(-[a-z]+){2}$/

      game = Games.get_game(game_id)
      assert game.deck == ~w(0 ½ 1 2 3 5 8 13 20 40 100 ? ☕)
      refute game.are_cards_revealed
    end

    test "creates a new game every time", %{game_id: game_id} do
      {:ok, other} = Games.create_game()

      refute other.id == game_id
      assert Repo.aggregate(Game, :count) == 2
    end
  end

  describe "join_game/1" do
    test "returns the game with its state", %{game_id: game_id} do
      Games.set_are_cards_revealed(game_id, true)

      assert {:ok, %Game{id: ^game_id, are_cards_revealed: true}} = Games.join_game(game_id)
    end

    test "does not create unknown games" do
      assert Games.join_game("sdfg") == {:error, :game_not_found}
      assert Repo.aggregate(Game, :count) == 1
    end
  end

  describe "set_are_cards_revealed/2" do
    test "toggles revealed cards", %{game_id: game_id} do
      assert Games.set_are_cards_revealed(game_id, true) == :ok
      assert Games.get_game(game_id).are_cards_revealed

      assert Games.set_are_cards_revealed(game_id, false) == :ok
      refute Games.get_game(game_id).are_cards_revealed
    end

    test "does not create unknown games" do
      assert Games.set_are_cards_revealed("sdfg", true) == {:error, :game_not_found}
      refute Games.get_game("sdfg")
    end
  end

  describe "delete_stale_games/0" do
    test "deletes games without activity for a week and keeps the others", %{game_id: game_id} do
      for {id, days} <- [{"recent", 6}, {"old", 8}] do
        Repo.insert!(%Game{id: id})
        backdate(id, days)
      end

      assert Games.delete_stale_games() == {:ok, 1}

      assert Games.get_game(game_id)
      assert Games.get_game("recent")
      refute Games.get_game("old")
    end
  end

  defp backdate(game_id, days) do
    updated_at = DateTime.utc_now() |> DateTime.add(-days, :day) |> DateTime.truncate(:second)
    Repo.update_all(from(g in Game, where: g.id == ^game_id), set: [updated_at: updated_at])
  end
end
