defmodule CattlePurchase.Repo.Migrations.UpdatePurchaseBasisPurchaseDetails do
  use Ecto.Migration

  def change do
    alter table(:purchase_details) do
      modify :purchase_basis, :decimal,  precision: 10, scale: 2
    end
  end
end
