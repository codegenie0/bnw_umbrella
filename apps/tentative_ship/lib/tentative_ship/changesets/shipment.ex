defmodule TentativeShip.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    LotPen,
    Destination
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "shipments" do
    field :head_shipped, :integer, default: 0
    field :ship_date, :date
    field :ship_week, :date
    field :ship_reference, :string
    field :total_ship_weight, :integer, default: 0
    belongs_to :lot_pen, LotPen
    belongs_to :destination, Destination

    timestamps()
  end

  def changeset(shipment, attrs \\ %{}) do
    shipment
    |> cast(attrs, [
      :head_shipped,
      :ship_date,
      :ship_week,
      :ship_reference,
      :total_ship_weight,
      :lot_pen_id,
      :destination_id])
  end
end
