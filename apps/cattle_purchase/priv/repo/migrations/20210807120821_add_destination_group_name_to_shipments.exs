defmodule CattlePurchase.Repo.Migrations.AddDestinationGroupNameToShipments do
  use Ecto.Migration

  def change do
    alter table("shipments") do
      add :destination_group_name, :string
    end
  end
end
