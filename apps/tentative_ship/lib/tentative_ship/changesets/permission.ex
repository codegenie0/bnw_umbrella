defmodule TentativeShip.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "permissions" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  def changeset(permission, attrs \\ %{}) do
    permission
    |> cast(attrs, [:name, :description])
  end
end
