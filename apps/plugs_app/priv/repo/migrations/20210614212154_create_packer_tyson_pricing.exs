defmodule PlugsApp.Repo.Migrations.CreatePackerTysonPricing do
  use Ecto.Migration

  def change do
    create table(:packer_tyson_pricing) do
      add :mpc_week_end_date,    :date
      add :usda,                 :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_tyson_base_price, :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_plt_yld_percent,  :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_prime,            :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_cab,              :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_select,           :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_no_roll,          :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_low_quality,      :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_heiferette,       :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_yg1,              :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_yg2,              :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_yg4,              :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_yg5,              :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_dn_549,           :decimal, precision: 12, scale: 2, default: 0.00
      add :reg_up_1050,          :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_base_price,       :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_plt_yld_percent,  :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_prime,            :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_select,           :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_no_roll,          :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_low_quality,      :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_yg1,              :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_yg2,              :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_yg4,              :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_yg5,              :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_dn_550,           :decimal, precision: 12, scale: 2, default: 0.00
      add :hol_up_1050,          :decimal, precision: 12, scale: 2, default: 0.00
    end
  end
end
