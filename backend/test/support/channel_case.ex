defmodule PokrWeb.ChannelCase do
  @moduledoc """
  Test case for channel tests. Game state is held in a named, global
  process, so tests using this case must not run async and use unique
  game ids (see `unique_game_id/0`).
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import PokrWeb.ChannelCase

      @endpoint PokrWeb.Endpoint
    end
  end

  def unique_game_id, do: "test-" <> Integer.to_string(System.unique_integer([:positive]))
end
