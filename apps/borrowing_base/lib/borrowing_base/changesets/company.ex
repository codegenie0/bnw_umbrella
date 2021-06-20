defmodule BorrowingBase.Company do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.{
    WeightBreak,
    Yard
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "companies" do
    field :name, :string
    has_many :yards, Yard
    has_many :weight_breaks, WeightBreak

    timestamps()
  end

  def changeset(company, attrs \\ %{}) do
    company
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :companies_name_index)
  end
end
