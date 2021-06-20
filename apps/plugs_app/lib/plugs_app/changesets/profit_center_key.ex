defmodule PlugsApp.ProfitCenterKey do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "turnkey_profit_center_key" do
    field :company,            :integer
    field :profit_center,      :integer
    field :profit_center_desc, :string
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :company,
          :profit_center,
          :profit_center_desc,
        ])
  end
end
