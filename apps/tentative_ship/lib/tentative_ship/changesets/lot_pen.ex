defmodule TentativeShip.LotPen do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    Lot,
    PenGradeYield
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "lot_pens" do
    field :pen_number, :string
    field :previous_pen, :string
    field :lot_name, :string
    field :lot_status_code, :string
    field :sex_code, :string
    field :origin, :string
    field :head_count_in, :integer, default: 0
    field :head_count_current, :integer, default: 0
    field :deads, :integer, default: 0
    field :pay_weight, :integer, default: 0
    field :current_weight, :decimal, default: 0
    field :est_ship_weight, :integer, default: 0
    field :in_date, :date
    field :proj_out_date, :date
    field :sort_group, :string
    field :terminal_sort, :string
    belongs_to :lot, Lot
    has_many :pen_grade_yields, PenGradeYield

    timestamps()
  end

  def changeset(lot_pen, attrs \\ %{}) do
    lot_pen
    |> cast(attrs, [
      :pen_number,
      :previous_pen,
      :lot_name,
      :lot_status_code,
      :sex_code,
      :origin,
      :head_count_in,
      :head_count_current,
      :deads,
      :pay_weight,
      :current_weight,
      :est_ship_weight,
      :in_date,
      :proj_out_date,
      :sort_group,
      :terminal_sort,
      :lot_id])
    |> cast_assoc(:pen_grade_yields, with: &PenGradeYield.changeset/2)
  end
end
