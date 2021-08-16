defmodule PlugsApp.Repo.Migrations.CreateOcb do
  use Ecto.Migration

  def change do
    create table(:ocb) do
      add :carcass_low, :integer, default: 0, null: 0
      add :carcass_high, :integer, default: 0, null: 0
      add :calculated_yield_grade, :decimal, default: 0.000, null: 0.000
      add :quality_grade, :string, null: ""
      add :add_30, :integer, default: 0, null: 0
      add :add_ag, :integer, default: 0, null: 0

      timestamps()
    end

    create unique_index(:ocb, [:carcass_low, :carcass_high, :calculated_yield_grade, :quality_grade, :add_30, :add_ag], name: :ocb_unique_key)
  end
end
