defmodule CustomerAccess.ReportType do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_customer_access"
  prefix = case Application.get_env(:customer_access, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "report_types" do
    field :name, :string

    timestamps()
  end

  def changeset(report_type, attrs \\ %{}) do
    report_type
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :report_types_name_index)
  end
end
