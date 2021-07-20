defmodule CattlePurchase.Repo.Migrations.AddPurchasePurchaseFlags do
  use Ecto.Migration

  def change do
    create table(:purchase_purchase_flags) do
      add :purchase_id, references(:purchases, null: false)
      add :purchase_flag_id, references(:purchase_flags, null: false)

      timestamps()
    end
    create unique_index(:purchase_purchase_flags, [:purchase_id, :purchase_flag_id], name: :purchase_purchase_flag_unique_index)
  end
end
