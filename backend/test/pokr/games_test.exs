defmodule Pokr.GamesTest do
  use Pokr.DataCase

  alias Pokr.{Game, Games}

  @deck ~w(S M L ? ☕)

  setup do
    {:ok, game} = Games.create_game(@deck)
    {:ok, game_id: game.id}
  end

  describe "create_game/1" do
    test "creates a game with a three word slug, the given deck and hidden cards", %{
      game_id: game_id
    } do
      assert game_id =~ ~r/^[a-z]+(-[a-z]+){2}$/

      game = Games.get_game(game_id)
      assert game.deck == @deck
      refute game.are_cards_revealed
    end

    test "creates a new game every time", %{game_id: game_id} do
      {:ok, other} = Games.create_game(@deck)

      refute other.id == game_id
      assert Repo.aggregate(Game, :count) == 2
    end
  end

  describe "valid_deck?/1" do
    test "accepts 2 to 20 distinct cards of up to 3 characters" do
      assert Games.valid_deck?(~w(1 2))
      assert Games.valid_deck?(~w(0 ½ 1 2 3 5 8 13 20 40 100 ? ☕))
      assert Games.valid_deck?(Enum.map(1..20, &Integer.to_string/1))
    end

    test "rejects decks of the wrong size" do
      refute Games.valid_deck?([])
      refute Games.valid_deck?(["1"])
      refute Games.valid_deck?(Enum.map(1..21, &Integer.to_string/1))
    end

    test "rejects duplicate cards" do
      refute Games.valid_deck?(~w(1 2 2))
    end

    test "rejects cards that are empty or longer than 3 characters" do
      refute Games.valid_deck?(["1", ""])
      refute Games.valid_deck?(~w(1 XXXL))
    end

    test "rejects anything but a list of strings" do
      refute Games.valid_deck?(nil)
      refute Games.valid_deck?("1 2 3")
      refute Games.valid_deck?([1, 2, 3])
      refute Games.valid_deck?(%{"0" => "1", "1" => "2"})
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

  describe "set_deck/2" do
    test "stores the new deck", %{game_id: game_id} do
      assert Games.set_deck(game_id, ~w(1 2 3)) == :ok
      assert Games.get_game(game_id).deck == ~w(1 2 3)
    end

    test "keeps the deck when the new one is invalid", %{game_id: game_id} do
      assert Games.set_deck(game_id, ~w(1 1)) == {:error, :invalid_deck}
      assert Games.get_game(game_id).deck == @deck
    end

    test "keeps the deck while the cards are revealed", %{game_id: game_id} do
      Games.set_are_cards_revealed(game_id, true)

      assert Games.set_deck(game_id, ~w(1 2 3)) == {:error, :cards_revealed}
      assert Games.get_game(game_id).deck == @deck
    end

    test "does not create unknown games" do
      assert Games.set_deck("sdfg", ~w(1 2 3)) == {:error, :game_not_found}
      refute Games.get_game("sdfg")
    end
  end

  describe "delete_stale_games/0" do
    test "deletes games without activity for a week and keeps the others", %{game_id: game_id} do
      for {id, days} <- [{"recent", 6}, {"old", 8}] do
        Repo.insert!(%Game{id: id, deck: @deck})
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
