defmodule PlugsApp.OutsideBillingCustomer do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "outside_billing_customer" do
    field :customer, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :customer,
        ])
    |> validate_required(:customer)
    |> unique_constraint(:customer, name: :ob_customer_unique_key)
  end
end
