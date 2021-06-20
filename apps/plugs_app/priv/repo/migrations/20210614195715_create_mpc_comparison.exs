defmodule PlugsApp.Repo.Migrations.CreateMpcComparison do
  use Ecto.Migration

  def change do
    create table(:mpc_comparison) do
      add :week_end_date, :date
      add :monday_date,   :date
      add :c_fax_price,   :decimal, precision: 12, scale: 2, default: 0.00
      add :c_fax_notes,   :string
      add :usda_price,    :decimal, precision: 12, scale: 2, default: 0.00
      add :usda_notes,    :string
      add :tt_price,      :decimal, precision: 12, scale: 2, default: 0.00
      add :tt_notes,      :string
    end
  end
end
