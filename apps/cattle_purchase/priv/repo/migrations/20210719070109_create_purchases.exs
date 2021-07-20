defmodule CattlePurchase.Repo.Migrations.CreatePurchases do
  use Ecto.Migration

  def change do
    create table(:purchases) do
      add :purchase_date, :date, null: false
      add :estimated_ship_date, :date, null: false
      add :firm, :boolean, default: false
      add :seller, :string
      add :origin, :string
      add :sex_id, references(:sexes, null: false)
      add :destination_group_id, references(:destination_groups, null: false)
      add :future_destination_group_id, references(:destination_groups, null: false)
      add :buyer_id, references(:purchase_buyers, null: false)
      add :purchase_type_id, references(:purchase_types, null: false)
      add :purchase_group_id, references(:purchase_groups, null: false)
      add :head_count, :integer, null: false
      add :projected_out_month, :integer
      add :projected_out_year, :integer
      add :price, :float, null: false
      add :weight, :float, null: false
      add :price_delivered, :boolean, default: false
      add :verify, :boolean, default: false
      add :complete, :boolean, default: false
      add :freight, :float, null: false
      add :comment, :text
      add :projected_break_even, :float, null: false
      add :projected_out_date, :date, null: false
      add :projected_placement_date, :date
      add :pasture, :string
      add :purchase_order, :string
      add :pcc_sort, :string
      add :pricing_order_date, :date
      add :customer_fill_date, :date
      add :wcc_fill_date, :date



      timestamps()
    end
  end
end
