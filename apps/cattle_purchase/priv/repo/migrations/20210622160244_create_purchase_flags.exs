defmodule CattlePurchase.Repo.Migrations.CreatePurchaseFlags do
  use Ecto.Migration

  def change do
    create table(:purchase_flags) do
      add :name, :string, null: false

      timestamps()
    end
  end
end
