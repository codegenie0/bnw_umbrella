defmodule PlugsApp.FuelUsageYard do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "fuel_usage_yard" do
    field :yard, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :yard
        ])
        |> validate_required(:yard)
        |> unique_constraint(:yard, name: :fuel_usage_yard_unique_constraint)
  end
end
