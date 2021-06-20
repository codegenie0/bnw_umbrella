defmodule PlugsApp.CompanyVehicleMile do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "company_vehicle_miles" do
    field :entry_date,  :date
    field :fy,          :string
    field :yard,        :integer
    field :driver_name, :string
    field :beginning,   :integer
    field :ending,      :integer
    field :miles,       :integer
    field :trip_miles,  :integer
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :entry_date,
          :fy,
          :yard,
          :driver_name,
          :beginning,
          :ending,
          :miles,
          :trip_miles,
        ])
  end
end
