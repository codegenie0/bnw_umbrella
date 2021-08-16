defmodule PlugsApp.Repo.Migrations.CreateCompanyVehicleMiles do
  use Ecto.Migration

  def change do
    create table(:company_vehicle_miles) do
      add :entry_date,  :date
      add :fy,          :integer, null: false
      add :yard,        :integer, null: false
      add :driver_name, :string
      add :beginning,   :integer
      add :ending,      :integer
      add :miles,       :integer
      add :trip_miles,  :integer

      timestamps()
    end

    create unique_index(:company_vehicle_miles, [:entry_date, :fy, :yard, :driver_name], name: :company_vehicle_miles_unique_key)
  end
end
