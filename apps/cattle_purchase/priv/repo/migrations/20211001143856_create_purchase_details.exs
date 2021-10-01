defmodule CattlePurchase.Repo.Migrations.CreatePurchaseDetails do
  use Ecto.Migration

  def change do
    create table(:purchase_details) do
      add :sex_id, references(:sexes, null: false)
      add :purchase_id, references(:purchases, null: false)
      add :purchase_page, :boolean, default: false, null: false
      add :head_count, :integer, null: false
      add :average_weight, :integer, null: false
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :projected_break_even, :decimal,  precision: 10, scale: 2, null: false
      add :purchase_basis, :decimal,  precision: 10, scale: 2, null: false
      add :futures_order_price, :decimal,  precision: 10, scale: 2
      add :cash_price, :decimal,  precision: 10, scale: 2
      add :projected_out_date, :date, null: false
      add :order_date, :date
      add :fill_date, :date

      timestamps()
    end
  end
end
