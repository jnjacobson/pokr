defmodule Pokr.Game do
  defstruct [
    deck: ~w(0 1 2 3 5 8 13 21 34 55 89 ?),
    are_cards_revealed: false,
    player_count: 0,
  ]
end
