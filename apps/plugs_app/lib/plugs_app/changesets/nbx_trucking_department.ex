defmodule PlugsApp.NbxTruckingDepartment do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "nbx_trucking_departments" do
    field :department, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :department
        ])
    |> validate_required(:department)
    |> unique_constraint(:department, name: :nbx_trucking_departments_unique_key)
  end
end
