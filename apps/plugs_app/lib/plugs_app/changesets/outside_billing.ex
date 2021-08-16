defmodule PlugsApp.OutsideBilling do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "outside_billing" do
    field :service_date, :date
    field :location,     :integer
    field :quantity,     :decimal
    field :price,        :decimal
    field :no_charge,    :boolean
    field :pass_thru,    :boolean
    field :comments,     :string
    field :service_type, :integer

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :service_date,
          :location,
          :quantity,
          :price,
          :no_charge,
          :pass_thru,
          :comments,
          :service_type,
        ])
    |> validate_required([:location, :service_type])
    |> unique_constraint([
        :service_date,
        :location,
        :service_type,
        :comments
    ],
    name: :outside_billing_unique_key)
  end
end
