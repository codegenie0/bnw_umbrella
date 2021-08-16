defmodule TentativeShip.Repo.Migrations.CreateLotOwners do
  use Ecto.Migration

  def change do
    create table(:lot_owners) do
      add :ownership_pct, :decimal, precision: 12, scale: 2, default: 0
      add :customer_id, references(:customers, on_delete: :nothing)
      add :lot_id, references(:lots, on_delete: :delete_all)

      timestamps()
    end

    create index(:lot_owners, [:lot_id, :customer_id], name: :lot_owners_main_index)
  end
end
