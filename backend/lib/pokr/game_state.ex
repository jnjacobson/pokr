defmodule Pokr.GameState do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @spec create_game(String.t()) :: :ok | :error
  def create_game(game_id) do
    game_exists = Agent.get(__MODULE__, fn state -> Map.has_key?(state, game_id) end)

    if game_exists do
      :error
    else
      Agent.update(__MODULE__, fn state ->
        Map.put(state, game_id, %Pokr.Game{})
      end)
    end
  end

  @spec delete_game(String.t()) :: :ok
  def delete_game(game_id) do
    Agent.update(__MODULE__, fn state ->
      Map.delete(state, game_id)
    end)
  end

  @spec set_are_cards_revealed(String.t(), boolean) :: :ok
  def set_are_cards_revealed(game_id, value) do
    Agent.update(__MODULE__, fn state ->
      put_in(state, [game_id, Access.key(:are_cards_revealed)], value)
    end)
  end

  @spec get_are_cards_revealed?(String.t()) :: boolean
  def get_are_cards_revealed?(game_id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, game_id).are_cards_revealed
    end)
  end

  @spec get_deck(String.t()) :: list(String.t())
  def get_deck(game_id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, game_id).deck
    end)
  end

  @spec increment_player_count(String.t()) :: :ok
  def increment_player_count(game_id) do
    Agent.update(__MODULE__, fn state ->
      update_in(state, [game_id, Access.key(:player_count)], fn count -> count + 1 end)
    end)
  end

  @spec decrement_player_count(String.t()) :: :ok
  def decrement_player_count(game_id) do
    if !has_players?(game_id) do
      :error
    end

    Agent.update(__MODULE__, fn state ->
      update_in(state, [game_id, Access.key(:player_count)], fn count -> count - 1 end)
    end)
  end

  @spec has_players?(String.t()) :: boolean()
  def has_players?(game_id) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, game_id).player_count > 0
    end)
  end
end
