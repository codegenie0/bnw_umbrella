defmodule PlugsApp.Repo.Migrations.CreateCompanyVehicleMiles do
  use Ecto.Migration

  def change do
    create table(:company_vehicle_miles) do
      add :entry_date,  :date
      add :fy,          :string
      add :yard,        :integer
      add :driver_name, :string
      add :beginning,   :integer
      add :ending,      :integer
      add :miles,       :integer
      add :trip_miles,  :integer
    end
  end
end
