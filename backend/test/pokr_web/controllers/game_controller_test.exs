defmodule PokrWeb.GameControllerTest do
  use PokrWeb.ConnCase, async: true

  @deck ~w(XS S M L XL ? ☕)

  test "POST /api/games creates a game with the given deck and returns its three word slug", %{
    conn: conn
  } do
    conn = post(conn, "/api/games", %{deck: @deck})

    assert %{"id" => id} = json_response(conn, 200)
    assert id =~ ~r/^[a-z]+(-[a-z]+){2}$/
    assert Pokr.Games.get_game(id).deck == @deck
  end

  test "POST /api/games returns a new id every time", %{conn: conn} do
    ids =
      for _ <- 1..5,
          do: post(conn, "/api/games", %{deck: @deck}) |> json_response(200) |> Map.fetch!("id")

    assert length(Enum.uniq(ids)) > 1
  end

  test "POST /api/games without a valid deck is unprocessable", %{conn: conn} do
    for params <- [%{}, %{deck: ["1"]}, %{deck: ~w(1 1)}, %{deck: "1 2 3"}] do
      conn = post(conn, "/api/games", params)

      assert json_response(conn, 422) == %{"errors" => %{"deck" => ["is invalid"]}}
    end

    assert Pokr.Repo.aggregate(Pokr.Game, :count) == 0
  end

  test "unknown API routes render the JSON error", %{conn: conn} do
    conn = conn |> put_req_header("accept", "application/json") |> get("/api/nope")

    assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
  end
end
