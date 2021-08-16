defmodule PlugsApp.Repo.Migrations.CreatePackerAbPricing do
  use Ecto.Migration

  def change do
    create table(:packer_ab_pricing) do
      add :mpc_week_end_date, :date
      add :usda,              :decimal, precision: 12, scale: 2, default: 0.00
      add :c_fax_6_state,     :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_ab_base_price, :decimal, precision: 12, scale: 2, default: 0.00
      add :usda_spread,       :decimal, precision: 12, scale: 2, default: 0.00
      add :plt_yld_percent,   :decimal, precision: 12, scale: 2, default: 0.00
      add :prime,             :decimal, precision: 12, scale: 2, default: 0.00
      add :double_r,          :decimal, precision: 12, scale: 2, default: 0.00
      add :choice_plus,       :decimal, precision: 12, scale: 2, default: 0.00
      add :choice_threshold,  :decimal, precision: 12, scale: 2, default: 0.00
      add :standard,          :decimal, precision: 12, scale: 2, default: 0.00
      add :commercial,        :decimal, precision: 12, scale: 2, default: 0.00
      add :no_roll,           :decimal, precision: 12, scale: 2, default: 0.00
      add :low_quality,       :decimal, precision: 12, scale: 2, default: 0.00
      add :yg1,               :decimal, precision: 12, scale: 2, default: 0.00
      add :yg2,               :decimal, precision: 12, scale: 2, default: 0.00
      add :yg4,               :decimal, precision: 12, scale: 2, default: 0.00
      add :yg5,               :decimal, precision: 12, scale: 2, default: 0.00
      add :underweight,       :decimal, precision: 12, scale: 2, default: 0.00
      add :overweight,        :decimal, precision: 12, scale: 2, default: 0.00
      add :plus_30_months,    :decimal, precision: 12, scale: 2, default: 0.00
      add :plus_30_2_percent, :decimal, precision: 12, scale: 2, default: 0.00

      timestamps()
    end

    create unique_index(:packer_ab_pricing, [:mpc_week_end_date], name: :packer_ab_pricing_unique_constraint)
  end
end
