defmodule BorrowingBase.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:companies, [:name])
  end
end
