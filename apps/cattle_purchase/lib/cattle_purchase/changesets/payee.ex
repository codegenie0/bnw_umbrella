defmodule CattlePurchase.Payee do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_cattle_purchase"
  prefix = case Mix.env do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix
  @primary_key {:id, :string, []}
  schema "payees" do
    field :name, :string
    field :vendor_number, :string
    field :lienholder, :string
  end

  def changeset(payee, params \\ %{}) do
    payee
    |> cast(params, [:id, :name, :vendor_number, :lienholder])
    |> validate_required([:name, :vendor_number])
    |> unique_constraint(:vendor_number, name: :payee_number_unique_index)
  end
end
