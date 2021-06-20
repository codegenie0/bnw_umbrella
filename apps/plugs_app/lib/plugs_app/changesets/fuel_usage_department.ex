defmodule PlugsApp.FuelUsageDepartment do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "fuel_usage_department" do
    field :department, :string
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :department
        ])
  end
end
