defmodule PlugsApp.Repo.Migrations.CreateFuelUsageYard do
  use Ecto.Migration

  def change do
    create table(:fuel_usage_yard) do
      add :yard, :string

      timestamps()
    end
    create unique_index(:fuel_usage_yard, :yard, name: :fuel_usage_yard_unique_constraint)
  end
end
