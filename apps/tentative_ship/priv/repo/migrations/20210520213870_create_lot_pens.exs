defmodule TentativeShip.Repo.Migrations.CreateLotPens do
  use Ecto.Migration

  def change do
    create table(:lot_pens) do
      add :pen_number, :string
      add :previous_pen, :string
      add :lot_name, :string
      add :lot_status_code, :string
      add :sex_code, :string
      add :origin, :string
      add :head_count_in, :integer, default: 0
      add :head_count_current, :integer, default: 0
      add :deads, :integer, default: 0
      add :pay_weight, :integer, default: 0
      add :current_weight, :decimal, precision: 12, scale: 2, default: 0
      add :est_ship_weight, :integer, default: 0
      add :in_date, :date
      add :proj_out_date, :date
      add :sort_group, :string
      add :terminal_sort, :string
      add :lot_id, references(:lots, on_delete: :delete_all)

      timestamps()
    end

    create index(:lot_pens, [:lot_id, :pen_number], name: :lot_pens_main_index)
  end
end
