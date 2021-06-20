defmodule PlugsApp.Repo.Migrations.CreateNbxTruckingDepartments do
  use Ecto.Migration

  def change do
    create table(:nbx_trucking_departments) do
      add :department, :string
    end
  end
end
