defmodule Pokr.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :string, size: 64, primary_key: true
      add :are_cards_revealed, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:games, [:updated_at])
  end
end
