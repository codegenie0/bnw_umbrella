defmodule PlugsApp.Repo.Migrations.CreateFuelUsageYard do
  use Ecto.Migration

  def change do
    create table(:fuel_usage_yard) do
      add :yard, :string
    end
  end
end
