defmodule CattlePurchase.Repo.Migrations.AddCheckboxesToPurchaseTypes do
  use Ecto.Migration

  def change do
    alter table(:purchase_types) do
      add :purchase_detail, :boolean, default: true, null: false
      add :seller, :boolean, default: true, null: false
      add :payee, :boolean, default: false, null: false
      add :commission, :boolean, default: false, null: false
      add :down_payments, :boolean, default: false, null: false
      add :contracts, :boolean, default: false, null: false
      add :futures_pricing, :boolean, default: false, null: false
    end
  end
end
