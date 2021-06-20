defmodule PlugsApp.Repo.Migrations.CreateFuelUsageType do
  use Ecto.Migration

  def change do
    create table(:fuel_usage_type) do
      add :type, :string
    end
  end
end
