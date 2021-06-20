defmodule PlugsApp.Repo.Migrations.CreateCompanyVehicleMilesYard do
  use Ecto.Migration

  def change do
    create table(:company_vehicle_miles_yard) do
      add :yard, :string
    end
  end
end
