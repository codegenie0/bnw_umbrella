defmodule PlugsApp.Repo.Migrations.CreateFuelUsageType do
  use Ecto.Migration

  def change do
    create table(:fuel_usage_type) do
      add :type, :string

      timestamps()
    end

    create unique_index(:fuel_usage_type, [:type], name: :fuel_usage_type_unique_key)
  end
end
