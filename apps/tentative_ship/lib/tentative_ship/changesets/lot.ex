defmodule TentativeShip.Lot do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.{
    LotOwner,
    LotPen
  }

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "lots" do
    field :lot_number, :string
    field :yard_number, :string
    field :active, :boolean, default: true
    has_many :lot_owners, LotOwner
    has_many :lot_pens, LotPen

    timestamps()
  end

  def changeset(lot, attrs \\ %{}) do
    lot
    |> cast(attrs, [
      :lot_number,
      :yard_number,
      :active])
    |> validate_required([:lot_number])
    |> cast_assoc(:lot_owners, with: &LotOwner.changeset/2)
    |> cast_assoc(:lot_pens, with: &LotPen.changeset/2)
  end
end
