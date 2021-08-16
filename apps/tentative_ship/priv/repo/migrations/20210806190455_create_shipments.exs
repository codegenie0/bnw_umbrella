defmodule TentativeShip.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add :lot_pen_id, references(:lot_pens, on_delete: :delete_all)
      add :destination_id, references(:destinations, on_delete: :delete_all)
      add :head_shipped, :integer, default: 0
      add :ship_date, :date
      add :ship_week, :date
      add :ship_reference, :string
      add :total_ship_weight, :integer, default: 0

      timestamps()
    end
  end
end
