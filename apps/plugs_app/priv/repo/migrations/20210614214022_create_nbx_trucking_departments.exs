defmodule PlugsApp.Repo.Migrations.CreateNbxTruckingDepartments do
  use Ecto.Migration

  def change do
    create table(:nbx_trucking_departments) do
      add :department, :string

      timestamps()
    end
    create unique_index(:nbx_trucking_departments, [:department], name: :nbx_trucking_departments_unique_key)
  end
end
