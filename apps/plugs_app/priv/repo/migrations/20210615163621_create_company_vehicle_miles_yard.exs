defmodule PlugsApp.Repo.Migrations.CreateCompanyVehicleMilesYard do
  use Ecto.Migration

  def change do
    create table(:company_vehicle_miles_yard) do
      add :yard, :string

      timestamps()
    end
    create unique_index(:company_vehicle_miles_yard, :yard, name: :company_vehicle_miles_yard_unique_constraint)
  end
end
