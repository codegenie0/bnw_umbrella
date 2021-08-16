defmodule TentativeShip.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :name, :string
      add :customer_number, :string, null: false
    end

    create unique_index(:customers, [:customer_number], name: :customers_unique_index)
  end
end
