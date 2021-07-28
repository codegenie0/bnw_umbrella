defmodule CattlePurchase.Repo.Migrations.AddPurchaseBasisToPurchases do
  use Ecto.Migration

  def change do
    alter table("purchases") do
      add :purchase_basis, :string
    end
  end
end
