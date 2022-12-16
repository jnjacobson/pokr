defmodule PokrWeb.Socket do
  use Phoenix.Socket

  channel "game:*", PokrWeb.GameChannel

  def connect(_params, socket) do
    {:ok, assign(socket, :id, UUID.uuid1())}
  end

  def id(socket), do: socket.assigns[:id]
end
