defmodule BorrowingBase.WeightBreak do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.{
    Company,
    EffectiveDate
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "weight_breaks" do
    field :name, :string
    belongs_to :company, Company
    has_many :effective_dates, EffectiveDate

    timestamps()
  end

  def changeset(weight_break, attrs \\ %{}) do
    weight_break
    |> cast(attrs, [:name, :company_id])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :weight_breaks_unique_index)
  end
end
