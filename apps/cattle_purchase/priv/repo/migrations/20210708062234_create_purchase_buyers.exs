defmodule CattlePurchase.Repo.Migrations.CreatePurchaseBuyers do
  use Ecto.Migration

  def change do
    create table(:purchase_buyers) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
