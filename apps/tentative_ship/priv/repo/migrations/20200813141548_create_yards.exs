defmodule TentativeShip.Repo.Migrations.CreateYards do
  use Ecto.Migration

  def change do
    create table(:yards) do
      add :name, :string, null: false
      add :external_id, :string

      timestamps()
    end

    create index(:yards, [:name, :external_id], name: :yards_main_index)
  end
end
