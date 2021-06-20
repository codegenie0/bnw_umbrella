defmodule BorrowingBase.EffectiveDate do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.{
    WeightBreak,
    WeightGroup
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "effective_dates" do
    field :effective_date, :date
    field :locked, :boolean
    belongs_to :weight_break, WeightBreak
    has_many :weight_groups, WeightGroup

    timestamps()
  end

  def changeset(effective_date, attrs \\ %{}) do
    effective_date
    |> cast(attrs, [:effective_date, :locked, :weight_break_id])
    |> validate_required([:effective_date])
    |> unique_constraint(:effective_date, name: :effective_dates_unique_index)
  end
end
