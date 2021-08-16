defmodule TentativeShip.LotStatusCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias TentativeShip.Yard

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "lot_status_codes" do
    field :name, :string
    field :description, :string
    belongs_to :yard, Yard

    timestamps()
  end

  def changeset(lot_status_code, params \\ %{}) do
    lot_status_code
    |> cast(params, [
      :name,
      :description,
      :yard_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :lot_status_codes_unique_index)
  end
end
