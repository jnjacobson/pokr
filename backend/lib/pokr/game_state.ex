defmodule Pokr.GameState do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec create_game(String.t()) :: :ok | :error
  def create_game(game_id) do
    game_exists = Agent.get(__MODULE__, &Map.has_key?(&1, game_id))

    if game_exists do
      :error
    else
      Agent.update(__MODULE__, &Map.put(&1, game_id, %Pokr.Game{}))
    end
  end

  @spec delete_game(String.t()) :: :ok
  def delete_game(game_id) do
    Agent.update(__MODULE__, &Map.delete(&1, game_id))
  end

  @spec set_are_cards_revealed(String.t(), boolean) :: :ok
  def set_are_cards_revealed(game_id, value) do
    Agent.update(__MODULE__, &put_in(&1, [game_id, Access.key(:are_cards_revealed)], value))
  end

  @spec get_are_cards_revealed?(String.t()) :: boolean
  def get_are_cards_revealed?(game_id) do
    Agent.get(__MODULE__, &Map.get(&1, game_id).are_cards_revealed)
  end

  @spec get_deck(String.t()) :: list(String.t())
  def get_deck(game_id) do
    Agent.get(__MODULE__, &Map.get(&1, game_id).deck)
  end

  @spec increment_player_count(String.t()) :: :ok
  def increment_player_count(game_id) do
    Agent.update(__MODULE__, &update_in(&1, [game_id, Access.key(:player_count)], fn count -> count + 1 end))
  end

  @spec decrement_player_count(String.t()) :: :ok
  def decrement_player_count(game_id) do
    case has_players?(game_id) do
      true ->
        Agent.update(__MODULE__, &update_in(&1, [game_id, Access.key(:player_count)], fn count -> count - 1 end))

      false ->
        :error
    end
  end

  @spec has_players?(String.t()) :: boolean()
  def has_players?(game_id) do
    Agent.get(__MODULE__, &Map.get(&1, game_id).player_count > 0)
  end
end
