defmodule BorrowingBase.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :name, :string, null: false
      add :url, :string, null: false

      timestamps()
    end

    create unique_index(:reports, [:name])
  end
end
