defmodule PlugsApp.FuelUsageType do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "fuel_usage_type" do
    field :type, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :type
        ])
    |> validate_required(:type)
    |> unique_constraint([:type], name: :fuel_usage_type_unique_key)
  end
end
