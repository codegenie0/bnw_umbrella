defmodule TentativeShip.Repo.Migrations.CreateLots do
  use Ecto.Migration

  def change do
    create table(:lots) do
      add :lot_number, :string, null: false
      add :yard_number, :string
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:lots, [:lot_number, :yard_number], name: :lots_main_index)
  end
end
