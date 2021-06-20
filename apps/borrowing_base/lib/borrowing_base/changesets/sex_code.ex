defmodule BorrowingBase.SexCode do
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

  schema "sex_codes" do
    field :gender, :string
    field :sex_code, :string
    belongs_to :company, Company

    timestamps()
  end

  def changeset(sex_code, attrs \\ %{}) do
    sex_code
    |> cast(attrs, [:gender, :sex_code, :company_id])
    |> validate_required([:gender, :sex_code])
    |> unique_constraint(:sex_code, name: :sex_codes_unique_index)
  end
end
