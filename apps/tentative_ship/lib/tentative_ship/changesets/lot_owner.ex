defmodule TentativeShip.LotOwner do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    Customer,
    Lot
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "lot_owners" do
    field :ownership_pct, :decimal, default: 0
    belongs_to :customer, Customer
    belongs_to :lot, Lot

    timestamps()
  end

  def changeset(lot, attrs \\ %{}) do
    lot
    |> cast(attrs, [
      :ownership_pct,
      :customer_id,
      :lot_id])
  end
end
