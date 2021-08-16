defmodule PlugsApp.Repo.Migrations.CreateCih do
  use Ecto.Migration

  def change do
    create table(:cih) do
      add :projected_out_weight, :integer, default: 0, null: 0
      add :max_out_weight, :integer, default: 0, null: 0
      add :railer_be, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :projected_be, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :projected_ship_days, :integer, default: 0, null: 0
      add :b_freight, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :n_freight, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :q_freight, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :b_bic, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :n_bic, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :q_bic, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :b_feed, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :n_feed, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :q_feed, :decimal, precision: 12, scale: 2, default: 0.00, null: 0.00
      add :tsp_days, :integer, default: 0, null: 0
      add :recalc_be_days, :integer, default: 0, null: 0
      add :recalc_feed_days, :integer, default: 0, null: 0
      add :update_flag, :integer, default: 0, null: 0

      timestamps()
    end

    create unique_index(:cih, [:projected_out_weight,
                               :max_out_weight,
                               :railer_be,
                               :projected_be,
                               :projected_ship_days,
                               :b_freight,
                               :n_freight,
                               :q_freight,
                               :b_bic,
                               :n_bic,
                               :q_bic,
                               :b_feed,
                               :n_feed,
                               :q_feed,
                               :tsp_days],
                             name: :cih_unique_key)
  end
end
