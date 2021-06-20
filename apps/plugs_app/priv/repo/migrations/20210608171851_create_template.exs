defmodule PlugsApp.Repo.Migrations.CreateTemplate do
  use Ecto.Migration

  def change do
    create table(:template) do
      add :co_month,                :date
      add :yard,                    :string
      add :lot,                     :string
      add :proj_dmc,                :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_other_costs,        :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_rations_costs,      :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_death_loss_percent, :decimal, precision: 12, scale: 2, default: 0.00
      add :op_percent,              :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_adg,                :decimal, precision: 12, scale: 2, default: 0.00
      add :fat_freight,             :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_cog_w_interest,     :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_be_wo_interest,     :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_be,                 :decimal, precision: 12, scale: 2, default: 0.00
      add :cnb_purchase_price,      :decimal, precision: 12, scale: 2, default: 0.00
      add :yard_lot,                :string
    end
  end
end
