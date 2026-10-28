defmodule Pokr.Games do
  @moduledoc """
  Games as stored in the `games` table. Players and their cards live in the
  clients and in `PokrWeb.Presence`; the table only holds what a rejoining
  client cannot restore on its own.
  """

  import Ecto.Query
  require Logger

  alias Pokr.{Game, Repo}

  @stale_after_days 7
  @deck_sizes 2..20
  @card_lengths 1..3

  @doc """
  Creates a game under a new random three word slug. The clients bring their
  own decks, so the deck only has to pass `valid_deck?/1`.
  """
  @spec create_game(term) :: {:ok, Game.t()} | {:error, :invalid_deck | :unavailable}
  def create_game(deck) do
    if valid_deck?(deck), do: create_game(deck, 5), else: {:error, :invalid_deck}
  end

  defp create_game(deck, attempts_left) do
    changeset =
      %Game{id: MnemonicSlugs.generate_slug(3), deck: deck}
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.unique_constraint(:id, name: :games_pkey)

    case guard(fn -> Repo.insert(changeset) end) do
      {:error, %Ecto.Changeset{}} when attempts_left > 1 -> create_game(deck, attempts_left - 1)
      {:error, %Ecto.Changeset{}} -> {:error, :unavailable}
      result -> result
    end
  end

  @doc """
  A deck is 2 to 20 distinct cards of 1 to 3 characters each, the most a card
  can show. Characters are graphemes, so `☕` counts as one.
  """
  @spec valid_deck?(term) :: boolean
  def valid_deck?(deck) when is_list(deck) do
    length(deck) in @deck_sizes and Enum.uniq(deck) == deck and
      Enum.all?(
        deck,
        &(is_binary(&1) and String.valid?(&1) and String.length(&1) in @card_lengths)
      )
  end

  def valid_deck?(_deck), do: false

  @doc "Swaps the deck of a game, which is only allowed while its cards are hidden."
  @spec set_deck(String.t(), term) ::
          :ok | {:error, :invalid_deck | :cards_revealed | :game_not_found | :unavailable}
  def set_deck(game_id, deck) do
    if valid_deck?(deck), do: swap_deck(game_id, deck), else: {:error, :invalid_deck}
  end

  defp swap_deck(game_id, deck) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    query = from(g in Game, where: g.id == ^game_id and not g.are_cards_revealed)

    case guard(fn -> {:ok, Repo.update_all(query, set: [deck: deck, updated_at: now])} end) do
      {:ok, {1, _}} ->
        :ok

      {:ok, {0, _}} ->
        if get_game(game_id), do: {:error, :cards_revealed}, else: {:error, :game_not_found}

      error ->
        error
    end
  end

  @doc "Marks an existing game as active."
  @spec join_game(String.t()) :: {:ok, Game.t()} | {:error, :game_not_found | :unavailable}
  def join_game(game_id) do
    case touch(game_id, []) do
      {:ok, game} -> {:ok, game}
      error -> error
    end
  end

  @spec set_are_cards_revealed(String.t(), boolean) ::
          :ok | {:error, :game_not_found | :unavailable}
  def set_are_cards_revealed(game_id, value) do
    with {:ok, _game} <- touch(game_id, are_cards_revealed: value), do: :ok
  end

  @spec get_game(String.t()) :: Game.t() | nil
  def get_game(game_id), do: Repo.get(Game, game_id)

  @doc "Deletes games that saw no activity for #{@stale_after_days} days."
  @spec delete_stale_games() :: {:ok, non_neg_integer} | {:error, :unavailable}
  def delete_stale_games do
    cutoff = DateTime.add(DateTime.utc_now(), -@stale_after_days, :day)

    with {:ok, {count, _}} <-
           guard(fn -> {:ok, Repo.delete_all(from g in Game, where: g.updated_at < ^cutoff)} end) do
      {:ok, count}
    end
  end

  defp touch(game_id, changes) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    query = from(g in Game, where: g.id == ^game_id, select: g)

    case guard(fn -> {:ok, Repo.update_all(query, set: [{:updated_at, now} | changes])} end) do
      {:ok, {1, [game]}} -> {:ok, game}
      {:ok, {0, []}} -> {:error, :game_not_found}
      error -> error
    end
  end

  defp guard(fun) do
    fun.()
  rescue
    error in [DBConnection.ConnectionError, Postgrex.Error] ->
      Logger.error("Database unavailable: " <> Exception.message(error))
      {:error, :unavailable}
  end
end
