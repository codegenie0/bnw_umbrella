defmodule PlugsApp.Repo.Migrations.CreateCompanyVehicleMilesFiscalYear do
  use Ecto.Migration

  def change do
    create table(:company_vehicle_miles_fiscal_year) do
      add :starting_year, :integer, null: false

      timestamps()
    end

    create unique_index(:company_vehicle_miles_fiscal_year, [:starting_year], name: :cmv_fy_unique_key)
  end

end
