defmodule BorrowingBase.Repo.Migrations.CreateLotAdjustments do
  use Ecto.Migration

  def change do
    create table(:lot_adjustments) do
      add :yard_name, :string
      add :yard_number, :string, size: 2
      add :customer_number, :string, size: 10
      add :customer_name, :string
      add :lot_number, :string, size: 10
      add :pen_number, :string, size: 10
      add :head_count_current, :decimal, precision: 12, scale: 2, default: 0, null: false
      add :sex_code, :string
      add :gender, :string
      add :average_current_weight, :decimal, precision: 12, scale: 2, default: 0, null: false
      add :lot_status_code, :string
      add :market_value, :decimal, precision: 12, scale: 2, default: 0, null: false
      add :total_value, :decimal, precision: 12, scale: 2, default: 0, null: false
      add :effective_date_id, references(:effective_dates, on_delete: :delete_all)
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end

    create index(:lot_adjustments, [:yard_number, :lot_number, :pen_number, :customer_number], name: :lot_adjustments_main_index)
  end
end
