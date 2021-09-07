defmodule CattlePurchase.Repo.Migrations.CreateCommissions do
  use Ecto.Migration

  def change do
    create table(:commissions) do
      add :commission_payee_id, references(:commission_payees, null: false)
      add :commission_per_hundred, :decimal, precision: 10, scale: 2, null: false
      add :purchase_id, references(:purchases, null: false)

      timestamps()
    end
  end
end
