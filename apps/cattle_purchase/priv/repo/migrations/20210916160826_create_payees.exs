defmodule CattlePurchase.Repo.Migrations.CreatePayees do
  use Ecto.Migration

  def change do
    create table(:payees, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :vendor_number, :string, null: false
      add :lienholder, :string
    end

    create unique_index(:payees, [:vendor_number], name: :payees_unique_index)
  end
end
