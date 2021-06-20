defmodule BorrowingBase.Repo.Migrations.CreateSexCodes do
  use Ecto.Migration

  def change do
    create table(:sex_codes) do
      add :gender, :string, null: false
      add :sex_code, :string, null: false
      add :company_id, references(:companies, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:sex_codes, [:sex_code, :company_id], name: :sex_codes_unique_index)
  end
end
