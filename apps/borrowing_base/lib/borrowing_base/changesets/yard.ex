defmodule BorrowingBase.Yard do
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

  schema "yards" do
    field :name, :string
    field :yard_number, :string
    field :external_name, :string
    belongs_to :company, Company

    timestamps()
  end

  def changeset(yard, attrs \\ %{}) do
    yard
    |> cast(attrs, [:name, :yard_number, :external_name, :company_id])
    |> validate_required([:name, :yard_number, :external_name])
    |> unique_constraint(:name, name: :yards_unique_index)
  end
end
