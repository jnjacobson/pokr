defmodule Pokr.Game do
  use Ecto.Schema

  @type t :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "games" do
    field :are_cards_revealed, :boolean, default: false
    field :deck, {:array, :string}

    timestamps(type: :utc_datetime)
  end
end
