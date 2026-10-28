defmodule Pokr.Repo.Migrations.AddDeckToGames do
  use Ecto.Migration

  def up do
    # Games predate decks and only a small team plays them, so they are dropped instead of backfilled.
    execute "DELETE FROM games"

    alter table(:games) do
      add :deck, {:array, :string}, null: false
    end
  end

  def down do
    alter table(:games) do
      remove :deck
    end
  end
end
