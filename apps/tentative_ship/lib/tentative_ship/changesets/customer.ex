defmodule TentativeShip.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_tentative_ship"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "customers" do
    field :name, :string
    field :customer_number, :string
  end

  def changeset(customer, params \\ %{}) do
    customer
    |> cast(params, [
      :id,
      :name,
      :customer_number])
    |> validate_required([:name, :customer_number])
    |> unique_constraint(:name, name: :customer_number_unique_index)
  end
end
