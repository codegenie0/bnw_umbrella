defmodule CattlePurchase.Repo.Migrations.CreatePurchaseGroups do
  use Ecto.Migration

  def change do
    create table(:purchase_groups) do
      add :name, :string, null: false
      add :include_in_partnership, :boolean, default: false, null: false
      add :include_in_kills, :boolean, default: false, null: false

      timestamps()
    end
  end
end
