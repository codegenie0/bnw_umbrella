defmodule BorrowingBase.LotAdjustment do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.{
    EffectiveDate,
    Yard
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "lot_adjustments" do
    field :yard_name, :string
    field :yard_number, :string
    field :customer_number, :string
    field :customer_name, :string
    field :lot_number, :string
    field :pen_number, :string
    field :head_count_current, :decimal
    field :sex_code, :string
    field :gender, :string
    field :genders, {:array, :string}, virtual: true
    field :average_current_weight, :decimal
    field :lot_status_code, :string
    field :market_value, :decimal
    field :total_value, :decimal
    belongs_to :effective_date, EffectiveDate
    belongs_to :yard, Yard

    timestamps()
  end

  def changeset(market_value_adjustment, attrs \\ %{}) do
    cast(market_value_adjustment, attrs, [
      :yard_name,
      :yard_number,
      :customer_number,
      :customer_name,
      :lot_number,
      :pen_number,
      :head_count_current,
      :sex_code,
      :gender,
      :genders,
      :average_current_weight,
      :lot_status_code,
      :market_value,
      :total_value,
      :effective_date_id,
      :yard_id
    ])
  end
end
