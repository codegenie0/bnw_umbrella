defmodule TentativeShip.PenGradeYield do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.LotPen

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "pen_grade_yields" do
    field :ship_reference, :string
    field :prime_count, :integer, default: 0
    field :choice_count, :integer, default: 0
    field :select_count, :integer, default: 0
    field :no_roll_count, :integer, default: 0
    field :low_grade_count, :integer, default: 0
    field :light_carcass_weight_count, :integer, default: 0
    field :heavy_carcass_weight_count, :integer, default: 0
    field :yield_grade_1_count, :integer, default: 0
    field :yield_grade_2_count, :integer, default: 0
    field :yield_grade_3_count, :integer, default: 0
    field :yield_grade_4_count, :integer, default: 0
    field :yield_grade_5_count, :integer, default: 0
    field :external_unique_key, :string
    belongs_to :lot_pen, LotPen

    timestamps()
  end

  def changeset(lot_pen, attrs \\ %{}) do
    lot_pen
    |> cast(attrs, [
      :ship_reference,
      :prime_count,
      :choice_count,
      :select_count,
      :no_roll_count,
      :low_grade_count,
      :light_carcass_weight_count,
      :heavy_carcass_weight_count,
      :yield_grade_1_count,
      :yield_grade_2_count,
      :yield_grade_3_count,
      :yield_grade_4_count,
      :yield_grade_5_count,
      :external_unique_key,
      :lot_pen_id])
  end
end
