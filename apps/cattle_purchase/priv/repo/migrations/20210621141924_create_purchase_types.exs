defmodule CattlePurchase.Repo.Migrations.CreatePurchaseTypes do
  use Ecto.Migration

  def change do
    create table(:purchase_types) do
      add :name, :string, null: false
      add :active, :boolean, default: false, null: false
      add :exclude, :boolean, default: false, null: false

      timestamps()
    end
  end
end
