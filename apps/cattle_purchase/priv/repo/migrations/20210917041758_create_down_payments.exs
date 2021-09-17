defmodule CattlePurchase.Repo.Migrations.CreateDownPayments do
  use Ecto.Migration

  def change do
    create table(:down_payments) do
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :locked, :boolean, default: false, null: false
      add :date_paid, :date, null: false
      add :purchase_id, references(:purchases, null: false)
      add :description, :text
      timestamps()
    end
  end
end
