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

  @doc "Creates the game if it is new and marks it as active."
  @spec join_game(String.t()) :: {:ok, Game.t()} | {:error, :unavailable}
  def join_game(game_id) do
    guard(fn ->
      Repo.insert(%Game{id: game_id},
        on_conflict: {:replace, [:updated_at]},
        conflict_target: :id,
        returning: true
      )
    end)
  end

  @spec set_are_cards_revealed(String.t(), boolean) :: :ok | {:error, :unavailable}
  def set_are_cards_revealed(game_id, value) do
    result =
      guard(fn ->
        Repo.insert(%Game{id: game_id, are_cards_revealed: value},
          on_conflict: {:replace, [:are_cards_revealed, :updated_at]},
          conflict_target: :id
        )
      end)

    with {:ok, _game} <- result, do: :ok
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

  defp guard(fun) do
    fun.()
  rescue
    error in [DBConnection.ConnectionError, Postgrex.Error] ->
      Logger.error("Database unavailable: " <> Exception.message(error))
      {:error, :unavailable}
  end
end
