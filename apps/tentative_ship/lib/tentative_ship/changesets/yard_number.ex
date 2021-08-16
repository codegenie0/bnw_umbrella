defmodule TentativeShip.YardNumber do
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

  schema "yard_numbers" do
    field :name, :string
    field :description, :string
    belongs_to :yard, Yard

    timestamps()
  end

  def changeset(yard_number, params \\ %{}) do
    yard_number
    |> cast(params, [
      :name,
      :description,
      :yard_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :yard_numbers_unique_index)
  end
end
