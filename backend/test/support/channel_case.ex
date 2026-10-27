defmodule PokrWeb.ChannelCase do
  @moduledoc """
  Test case for channel tests. Channel processes share the test's database
  connection, so tests using this case must not run async. Every test runs
  in a sandboxed transaction that is rolled back at the end.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import PokrWeb.ChannelCase

      @endpoint PokrWeb.Endpoint
    end
  end

  setup tags do
    Pokr.DataCase.setup_sandbox(tags)
    :ok
  end

  def unique_game_id, do: "test-" <> Integer.to_string(System.unique_integer([:positive]))
end
