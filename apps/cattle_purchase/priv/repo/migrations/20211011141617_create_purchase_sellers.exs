defmodule CattlePurchase.Repo.Migrations.CreatePurchaseSellers do
  use Ecto.Migration

  def change do
    create table(:purchase_sellers) do
      add :purchase_id, references(:purchases, null: false)
      add :seller_id, references(:sellers, null: false)

      timestamps()
    end
    create unique_index(:purchase_sellers, [:purchase_id, :seller_id], name: :purchase_seller_unique_index)
  end
end
