defmodule PokrWeb.GameController do
  use PokrWeb, :controller

  def create(conn, _params) do
    case Pokr.Games.create_game() do
      {:ok, game} ->
        json(conn, %{id: game.id})

      {:error, :unavailable} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{errors: %{detail: "Service Unavailable"}})
    end
  end
end
