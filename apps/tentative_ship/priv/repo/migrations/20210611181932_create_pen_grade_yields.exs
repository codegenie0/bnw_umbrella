defmodule TentativeShip.Repo.Migrations.CreatePenGradeYields do
  use Ecto.Migration

  def change do
    create table(:pen_grade_yields) do
      add :ship_reference, :string
      add :prime_count, :integer, default: 0
      add :choice_count, :integer, default: 0
      add :select_count, :integer, default: 0
      add :no_roll_count, :integer, default: 0
      add :low_grade_count, :integer, default: 0
      add :light_carcass_weight_count, :integer, default: 0
      add :heavy_carcass_weight_count, :integer, default: 0
      add :yield_grade_1_count, :integer, default: 0
      add :yield_grade_2_count, :integer, default: 0
      add :yield_grade_3_count, :integer, default: 0
      add :yield_grade_4_count, :integer, default: 0
      add :yield_grade_5_count, :integer, default: 0
      add :external_unique_key, :string
      add :lot_pen_id, references(:lot_pens, on_delete: :delete_all)

      timestamps()
    end

    create index(:pen_grade_yields, [:ship_reference, :lot_pen_id], name: :lot_owners_main_index)
  end
end
