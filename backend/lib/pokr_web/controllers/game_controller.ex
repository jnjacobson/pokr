defmodule PokrWeb.GameController do
  use PokrWeb, :controller

  def create(conn, _params) do
    json(conn, %{id: MnemonicSlugs.generate_slug(3)})
  end
end
