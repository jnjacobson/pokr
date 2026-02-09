defmodule PokrWeb.Socket do
  use Phoenix.Socket

  channel "game:*", PokrWeb.GameChannel

  def connect(params, socket) do
    player_id = params["player_id"]
    token = params["token"]

    case verify_token(player_id, token) do
      {:ok, verified_id} ->
        {:ok, assign(socket, :id, verified_id)}

      :error ->
        new_id = UUID.uuid1()
        {:ok, assign(socket, :id, new_id)}
    end
  end

  defp verify_token(nil, _), do: :error
  defp verify_token(_, nil), do: :error

  defp verify_token(player_id, token) do
    case Phoenix.Token.verify(PokrWeb.Endpoint, "player-token-salt", token, max_age: 86400 * 30) do
      {:ok, ^player_id} -> {:ok, player_id}
      _ -> :error
    end
  end

  def id(socket), do: socket.assigns[:id]
end
