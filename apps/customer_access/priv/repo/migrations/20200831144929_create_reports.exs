defmodule CustomerAccess.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :name, :string, null: false
      add :url, :text, null: false
      add :report_type_id, references(:report_types, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:reports, [:name])
  end
end
