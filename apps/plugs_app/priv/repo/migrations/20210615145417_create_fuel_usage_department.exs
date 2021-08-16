defmodule PlugsApp.Repo.Migrations.CreateFuelUsageDepartment do
  use Ecto.Migration

  def change do
    create table(:fuel_usage_department) do
      add :department, :string

      timestamps()
    end
    create unique_index(:fuel_usage_department, [:department], name: :fuel_usage_departments_unique_key)
  end
end
