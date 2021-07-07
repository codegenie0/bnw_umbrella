defmodule CattlePurchase.Repo.Migrations.CreatePurchaseTypePurchaseTypeFilters do
  use Ecto.Migration

  def change do
    create table(:purchase_type_purchase_type_filters) do
      add :purchase_type_id, references(:purchase_types, null: false)
      add :purchase_type_filter_id, references(:purchase_type_filters, null: false)

      timestamps()
    end
    create unique_index(:purchase_type_purchase_type_filters, [:purchase_type_id, :purchase_type_filter_id], name: :purchase_type_filters_unique_index)
  end
end
