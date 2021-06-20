defmodule BorrowingBase.LotStatusCode do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.Company

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "lot_status_codes" do
    field :lot_status_code, :string
    belongs_to :company, Company

    timestamps()
  end

  def changeset(lot_status_code, attrs \\ %{}) do
    lot_status_code
    |> cast(attrs, [:lot_status_code, :company_id])
    |> validate_required([:lot_status_code])
    |> unique_constraint(:lot_status_code, name: :lot_status_codes_unique_index)
  end
end
