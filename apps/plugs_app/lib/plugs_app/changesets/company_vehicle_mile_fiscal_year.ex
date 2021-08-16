defmodule PlugsApp.CompanyVehicleMileFiscalYear do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end

  @schema_prefix prefix

  schema "company_vehicle_miles_fiscal_year" do
    field :starting_year, :integer

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :starting_year,
        ])
    |> unique_constraint([:starting_year], name: :cmv_fy_unique_key)
  end
end
