defmodule Reimbursement.Rate do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_reimbursement"
  prefix = case Application.get_env(:reimbursement, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "mileage_rates" do
    field :year, :integer
    field :value, :decimal
  end

  def changeset(plug, attrs \\ %{}) do
    plug
      |> cast(attrs, [
        :year,
        :value])
        |> unique_constraint(:year, name: :year_unique_index, message: "Invalid Year - Must be unique")
        |> validate_required(:value, message: "Invalid Rate - Must enter a value")
        |> validate_number(:value, greater_than: 0.000, message: "Invalid Rate - Must be greater then 0")
  end
end
