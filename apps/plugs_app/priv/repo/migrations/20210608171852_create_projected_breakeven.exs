defmodule PlugsApp.Repo.Migrations.CreateProjectedBreakeven do
  use Ecto.Migration

  def change do
    create table(:projected_breakeven_data) do
      add :co_month,                :date
      add :yard,                    :integer, null: false
      add :lot,                     :string
      add :proj_dmc,                :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_other_costs,        :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_rations_costs,      :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_death_loss_percent, :decimal, precision: 12, scale: 2, default: 0.00
      add :op_percent,              :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_adg,                :decimal, precision: 12, scale: 2, default: 0.00
      add :fat_freight,             :decimal, precision: 12, scale: 2, default: 0.00
      add :proj_cog_w_interest,     :decimal, precision: 12, scale: 4, default: 0.0000
      add :proj_be_wo_interest,     :decimal, precision: 12, scale: 4, default: 0.0000
      add :proj_be,                 :decimal, precision: 12, scale: 4, default: 0.0000
      add :cnb_purchase_price,      :decimal, precision: 12, scale: 4, default: 0.0000
      add :yard_lot,                :string

      timestamps()
    end

    create unique_index(:projected_breakeven_data, [:co_month, :yard, :lot], name: :projected_breakeven_unique_constraint)
  end
end
