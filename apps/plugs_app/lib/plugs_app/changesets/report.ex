defmodule PlugsApp.Report do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev  -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "reports" do
    field :plug_name,   :string
    field :report_name, :string
    field :report_url,  :string

    timestamps()
  end

  def changeset(report, attrs \\ %{}) do
    report
    |> cast(attrs, [
          :plug_name,
          :report_name,
          :report_url,
        ])
        |> unique_constraint([
      :plug_name,
      :report_name
    ],
    name: :report_unique_key)
  end
end
