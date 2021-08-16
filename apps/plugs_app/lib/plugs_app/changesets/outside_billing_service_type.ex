defmodule PlugsApp.OutsideBillingServiceType do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end

  @schema_prefix prefix

  schema "outside_billing_service_type" do
    field :service_type, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :service_type,
        ])
    |> validate_required(:service_type)
    |> unique_constraint([:service_type], name: :ob_st_unique_constraint)
  end
end
