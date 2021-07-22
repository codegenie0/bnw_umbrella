defmodule CattlePurchase.Repo.Migrations.AddDestinationGroupNameToPurchases do
  use Ecto.Migration

  def change do
    alter table("purchases") do
      add :destination_group_name, :string, null: false
    end
  end
end
