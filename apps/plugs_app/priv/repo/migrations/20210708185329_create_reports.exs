defmodule PlugsApp.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :plug_name,   :string
      add :report_name, :string
      add :report_url,  :string

      timestamps()
    end

    create unique_index(:reports, [
          :plug_name,
          :report_name
        ],
        name: :report_unique_key)
  end
end
