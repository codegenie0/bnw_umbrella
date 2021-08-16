defmodule PlugsApp.Ocb do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end

  @schema_prefix prefix

  schema "ocb" do
    field :carcass_low, :integer
    field :carcass_high, :integer
    field :calculated_yield_grade, :decimal
    field :quality_grade, :string
    field :add_30, :integer
    field :add_ag, :integer

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :carcass_low,
          :carcass_high,
          :calculated_yield_grade,
          :quality_grade,
          :add_30,
          :add_ag])
    |> unique_constraint([:carcass_low, :carcass_high, :calculated_yield_grade, :quality_grade, :add_30, :add_ag], name: :ocb_unique_key)
  end
end
