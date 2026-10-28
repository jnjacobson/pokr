defmodule PokrWeb.GameController do
  use PokrWeb, :controller

  def create(conn, params) do
    case Pokr.Games.create_game(params["deck"]) do
      {:ok, game} ->
        json(conn, %{id: game.id})

      {:error, :invalid_deck} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{deck: ["is invalid"]}})

      {:error, :unavailable} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{errors: %{detail: "Service Unavailable"}})
    end
  end
end
