defmodule BorrowingBase.Repo.Migrations.CreateYards do
  use Ecto.Migration

  def change do
    create table(:yards) do
      add :name, :string, null: false
      add :yard_number, :string, null: false
      add :external_name, :string, null: false
      add :company_id, references(:companies, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:yards, [:name, :company_id], name: :yards_unique_index)
  end
end
