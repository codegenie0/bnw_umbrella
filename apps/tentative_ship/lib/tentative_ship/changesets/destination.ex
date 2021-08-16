defmodule TentativeShip.Destination do
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

  schema "destinations" do
    field :name, :string
    field :description, :string
    field :terminal, :boolean, default: true
    belongs_to :yard, Yard

    timestamps()
  end

  def changeset(destination, params \\ %{}) do
    destination
    |> cast(params, [
      :name,
      :description,
      :terminal,
      :yard_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :destinations_unique_index)
  end
end
