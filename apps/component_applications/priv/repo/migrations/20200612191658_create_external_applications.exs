defmodule ComponentApplications.Repo.Migrations.CreateExternalApplications do
  use Ecto.Migration

  def change do
    create table(:external_applications) do
      add :name, :string, null: false
      add :url, :text, null: false

      timestamps()
    end

    create unique_index(:external_applications, [:name])
  end
end
