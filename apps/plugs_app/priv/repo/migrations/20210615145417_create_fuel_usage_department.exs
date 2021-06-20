defmodule PlugsApp.Repo.Migrations.CreateFuelUsageDepartment do
  use Ecto.Migration

  def change do
    create table(:fuel_usage_department) do
      add :department, :string
    end
  end
end
