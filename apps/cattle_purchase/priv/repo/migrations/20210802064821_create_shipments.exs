defmodule CattlePurchase.Repo.Migrations.CreateShipments do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add :purchase_id, references(:purchases, null: false)
      add :estimated_ship_date, :date, null: false
      add :head_count, :integer, null: false
      add :destination_group_id, references(:destination_groups, null: false)
      add :firm, :boolean, default: false
      add :complete, :boolean, default: false
      add :projected_out_date, :date, null: false
      add :sex_id, references(:sexes, null: false)
      add :expected_lots, :integer


      timestamps()
    end
  end
end
