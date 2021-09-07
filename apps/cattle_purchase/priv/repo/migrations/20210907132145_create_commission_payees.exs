defmodule CattlePurchase.Repo.Migrations.CreateCommissionPayees do
  use Ecto.Migration

  def change do
    create table(:commission_payees) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
