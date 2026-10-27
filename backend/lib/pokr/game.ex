defmodule Pokr.Game do
  use Ecto.Schema

  @default_deck ~w(0 ½ 1 2 3 5 8 13 20 40 100 ? ☕)

  @type t :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: false}
  schema "games" do
    field :are_cards_revealed, :boolean, default: false
    field :deck, {:array, :string}, virtual: true, default: @default_deck

    timestamps(type: :utc_datetime)
  end
end
