defmodule PokrWeb.Socket do
  use Phoenix.Socket

  require Logger

  channel "games:*", PokrWeb.GameChannel

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
