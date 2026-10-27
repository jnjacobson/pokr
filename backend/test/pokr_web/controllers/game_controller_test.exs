defmodule PokrWeb.GameControllerTest do
  use PokrWeb.ConnCase, async: true

  test "POST /api/games creates a game and returns its three word slug", %{conn: conn} do
    conn = post(conn, "/api/games")

    assert %{"id" => id} = json_response(conn, 200)
    assert id =~ ~r/^[a-z]+(-[a-z]+){2}$/
    assert Pokr.Games.get_game(id)
  end

  test "POST /api/games returns a new id every time", %{conn: conn} do
    ids = for _ <- 1..5, do: post(conn, "/api/games") |> json_response(200) |> Map.fetch!("id")

    assert length(Enum.uniq(ids)) > 1
  end

  test "unknown API routes render the JSON error", %{conn: conn} do
    conn = conn |> put_req_header("accept", "application/json") |> get("/api/nope")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
  end
end
