defmodule PlugsApp.Repo.Migrations.CreateFuelUsage do
  use Ecto.Migration

  def change do
    create table(:fuel_usage) do
      add :start_date, :date
      add :yard,       :integer
      add :type,       :integer
      add :department, :integer
      add :gallons,    :decimal, precision: 12, scale: 2, default: 0.00
      add :amount,     :decimal, precision: 12, scale: 2, default: 0.00
    end
  end
end
