defmodule PlugsApp.Repo.Migrations.CreateFuelUsage do
  use Ecto.Migration

  def change do
    create table(:fuel_usage) do
      add :start_date,   :date
      add :yard,         :integer, null: false
      add :type,         :integer, null: false
      add :department,   :integer, null: false
      add :gallons,      :decimal, precision: 12, scale: 2, default: 0.00
      add :amount,       :decimal, precision: 12, scale: 2, default: 0.00
      add :price_gallon, :decimal, precision: 12, scale: 2, default: 0.00

      timestamps()
    end

    create unique_index(:fuel_usage, [:start_date, :yard, :type, :department], name: :fuel_usage_uniqu_constraint)
  end
end
