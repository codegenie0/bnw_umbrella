defmodule BorrowingBase.Repo.Migrations.CreateWeightBreaksLotStatusCodes do
  use Ecto.Migration

  def change do
    create table(:weight_breaks_lot_status_codes) do
      add :weight_break_id, references(:weight_breaks, on_delete: :delete_all)
      add :lot_status_code_id, references(:lot_status_codes, on_delete: :delete_all)
    end

    create unique_index(:weight_breaks_lot_status_codes, [:lot_status_code_id], name: :wb_lsc_unique_index)
  end
end
