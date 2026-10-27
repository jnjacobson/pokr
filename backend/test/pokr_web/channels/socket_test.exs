defmodule PokrWeb.SocketTest do
  use PokrWeb.ChannelCase

  defp token(player_id), do: Phoenix.Token.sign(PokrWeb.Endpoint, "player-token-salt", player_id)

  test "keeps the player id when the token is valid" do
    assert {:ok, socket} =
             connect(PokrWeb.Socket, %{"player_id" => "player-1", "token" => token("player-1")})

    assert socket.assigns.id == "player-1"
  end

  test "assigns a new id when no credentials are given" do
    assert {:ok, socket} = connect(PokrWeb.Socket, %{})
    assert is_binary(socket.assigns.id)
  end

  test "assigns a new id when the token belongs to another player" do
    assert {:ok, socket} =
             connect(PokrWeb.Socket, %{"player_id" => "player-1", "token" => token("player-2")})

    refute socket.assigns.id in ["player-1", "player-2"]
  end

  test "assigns a new id when the token is garbage" do
    assert {:ok, socket} =
             connect(PokrWeb.Socket, %{"player_id" => "player-1", "token" => "nope"})

    refute socket.assigns.id == "player-1"
  end
end
