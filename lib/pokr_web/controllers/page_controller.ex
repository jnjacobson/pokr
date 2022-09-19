defmodule PokrWeb.PageController do
  use PokrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
