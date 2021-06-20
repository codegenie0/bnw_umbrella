defmodule CustomerAccess.Repo.Migrations.CreateReportTypes do
  use Ecto.Migration

  def change do
    create table(:report_types) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:report_types, [:name])
  end
end
