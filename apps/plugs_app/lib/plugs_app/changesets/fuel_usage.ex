defmodule PlugsApp.FuelUsage do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "fuel_usage" do
    field :start_date, :date
    field :yard,       :integer
    field :type,       :integer
    field :department, :integer
    field :gallons,    :decimal
    field :amount,     :decimal
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :start_date,
          :yard,
          :type,
          :department,
          :gallons,
          :amount,
        ])
  end
end
