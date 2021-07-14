defmodule CattlePurchase.Repo.Migrations.AlterIdSequenceForPurchaseBuyers do
  use Ecto.Migration

  def change do
    execute """
    ALTER TABLE purchase_buyers AUTO_INCREMENT = 80000;
    """
  end
end
