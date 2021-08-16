defmodule PlugsApp.FourteenDayUsage do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
             :dev -> prefix <> "_dev"
             :test -> prefix <> "_test"
             _ -> prefix
           end

  @schema_prefix prefix

  schema "fourteen_day_usage" do
    field :yard,             :integer
    field :commodity,        :integer
    field :inventory_amount, :integer
    field :usage_pounds,     :integer
    field :receiving_pounds, :integer

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :yard,
          :commodity,
          :inventory_amount,
          :usage_pounds,
          :receiving_pounds,
        ])
    |> validate_required([:yard, :commodity])
    |> unique_constraint([
      :yard,
      :commodity,
      :inventory_amount,
      :usage_pounds,
      :receiving_pounds,
    ],
    name: :fourteen_day_usage_unique_key)
  end
end
