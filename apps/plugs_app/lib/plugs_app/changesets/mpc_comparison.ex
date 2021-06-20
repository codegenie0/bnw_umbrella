defmodule PlugsApp.MpcComparison do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "mpc_comparison" do
    field :week_end_date, :date
    field :monday_date,   :date
    field :c_fax_price,   :decimal
    field :c_fax_notes,   :string
    field :usda_price,    :decimal
    field :usda_notes,    :string
    field :tt_price,      :decimal
    field :tt_notes,      :string
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :week_end_date,
          :monday_date,
          :c_fax_price,
          :c_fax_notes,
          :usda_price,
          :usda_notes,
          :tt_price,
          :tt_notes,
        ])
  end
end
