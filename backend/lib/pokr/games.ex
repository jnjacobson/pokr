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

  @doc "Creates a game under a new random three word slug."
  @spec create_game() :: {:ok, Game.t()} | {:error, :unavailable}
  def create_game, do: create_game(5)

  defp create_game(attempts_left) do
    changeset =
      %Game{id: MnemonicSlugs.generate_slug(3)}
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.unique_constraint(:id, name: :games_pkey)

    case guard(fn -> Repo.insert(changeset) end) do
      {:error, %Ecto.Changeset{}} when attempts_left > 1 -> create_game(attempts_left - 1)
      {:error, %Ecto.Changeset{}} -> {:error, :unavailable}
      result -> result
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
