defmodule CattlePurchase.Repo.Migrations.CreatePurchasePayees do
  use Ecto.Migration

  def change do
    create table(:purchase_payees) do
      add :purchase_id, references(:purchases, null: false)
      add :payee_id, references(:payees, column: :id, type: :string, null: false)

      timestamps()
    end
    create unique_index(:purchase_payees, [:purchase_id, :payee_id], name: :purchase_payee_unique_index)
  end
end
