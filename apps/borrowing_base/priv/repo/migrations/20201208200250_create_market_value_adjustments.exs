defmodule BorrowingBase.Repo.Migrations.CreateMarketValueAdjustments do
  use Ecto.Migration

  def change do
    create table(:market_value_adjustments) do
      add :adjustment_type, :string, default: "increment", null: false
      add :amount, :decimal, precision: 12, scale: 2, default: 0, null: false
      add :customer_number, :string
      add :gender, :string
      add :effective_date_id, references(:effective_dates, on_delete: :delete_all)
      add :yard_id, references(:yards, on_delete: :delete_all)

      timestamps()
    end
  end
end
