defmodule PlugsApp.OutsideBillingLocation do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "outside_billing_location" do
    field :customer, :integer
    field :location, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :customer,
          :location,
        ])
    |> validate_required([:location, :customer])
    |> unique_constraint([:cusomer, :location], name: :ob_location_unique_key)
  end
end
