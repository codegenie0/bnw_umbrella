defmodule CattlePurchase.Repo.Migrations.AddPurchaseIdToPurchaseDetail do
  use Ecto.Migration

  def change do
    alter table(:purchase_details) do
      add :purchase_id, references(:purchases, null: false)
    end
  end
end
