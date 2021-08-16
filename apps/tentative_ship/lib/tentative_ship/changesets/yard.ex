defmodule TentativeShip.Yard do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "yards" do
    field :name, :string
    field :external_id, :string

    timestamps()
  end

  def changeset(yard, attrs \\ %{}) do
    yard
    |> cast(attrs, [
      :name,
      :external_id])
  end
end
