defmodule BorrowingBase.Repo.Migrations.CreateLotStatusCodes do
  use Ecto.Migration

  def change do
    create table(:lot_status_codes) do
      add :lot_status_code, :string, null: false
      add :company_id, references(:companies, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:lot_status_codes, [:lot_status_code, :company_id], name: :lot_status_codes_unique_index)
  end
end
