defmodule CattlePurchase.Repo.Migrations.CreateContractTerms do
  use Ecto.Migration

  def change do
    create table(:contract_terms) do
      add :name, :string, null: false
      add :description, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end
  end
end
