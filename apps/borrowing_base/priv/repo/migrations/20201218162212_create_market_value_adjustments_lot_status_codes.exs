defmodule BorrowingBase.Repo.Migrations.CreateMarketValueAdjustmentsLotStatusCodes do
  use Ecto.Migration

  def change do
    create table(:adjustments_lot_status_codes) do
      add :market_value_adjustment_id, references(:market_value_adjustments, on_delete: :delete_all)
      add :lot_status_code_id, references(:lot_status_codes, on_delete: :delete_all)
    end
  end
end
