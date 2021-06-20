defmodule CustomerAccess.CustomerReportType do
  use Ecto.Schema
  import Ecto.Changeset

  alias CustomerAccess.{
    Customer,
    ReportType
  }

  prefix = "bnw_dashboard_customer_access"
  prefix = case Application.get_env(:customer_access, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "customers_report_types" do
    belongs_to :customer, Customer, foreign_key: :user_id
    belongs_to :report_type, ReportType
  end

  def changeset(customer_report_type, attrs \\ %{}) do
    customer_report_type
    |> cast(attrs, [:user_id, :report_type_id])
  end
end
