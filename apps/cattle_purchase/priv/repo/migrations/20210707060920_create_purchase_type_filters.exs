defmodule CattlePurchase.Repo.Migrations.CreatePurchaseTypeFilters do
  use Ecto.Migration

  def change do
    create table(:purchase_type_filters) do
      add :name, :string, null: false
      add :default_group, :boolean, default: false

      timestamps()
    end
  end
end
