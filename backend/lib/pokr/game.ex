defmodule Pokr.Game do
  defstruct [
    deck: ~w(0 ½ 1 2 3 5 8 13 20 40 100 ☕ ?),
    are_cards_revealed: false,
    player_count: 0,
  ]
end
