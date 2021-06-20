defmodule Reimbursement.Report do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_reimbursement"
  prefix = case Application.get_env(:reimbursement, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "report_url" do
    field :url,     :string
    field :name,    :string
    field :active,  :boolean
    field :primary, :boolean
  end

  def changeset(report, attrs \\ %{}) do
    report
    |> cast(attrs, [
          :url,
          :name,
          :active,
          :primary
        ])
    |> validate_required([:name, :url], message: "can't be blank")
  end
end
