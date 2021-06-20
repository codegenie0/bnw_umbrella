defmodule CustomerAccess.Report do
  use Ecto.Schema
  import Ecto.Changeset

  alias CustomerAccess.ReportType

  prefix = "bnw_dashboard_customer_access"
  prefix = case Application.get_env(:customer_access, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "reports" do
    field :name, :string
    field :url, :string
    belongs_to :report_type, ReportType

    timestamps()
  end

  def changeset(report, attrs \\ %{}) do
    report
    |> cast(attrs, [:name, :url, :report_type_id])
    |> validate_required([:name, :url])
    |> unique_constraint(:name, name: :reports_name_index)
    |> check_url()
  end

  defp check_url(changeset) do
    {_, url} = fetch_field(changeset, :url)
    cond do
      String.starts_with?(url || "", ["https://"]) ->
        changeset
      true ->
        add_error(changeset, :url, "must begin with 'https://'")
    end
  end
end
