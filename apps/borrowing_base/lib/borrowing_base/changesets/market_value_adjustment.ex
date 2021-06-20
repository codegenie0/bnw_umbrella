defmodule BorrowingBase.MarketValueAdjustment do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.{
    EffectiveDate,
    LotStatusCode,
    Yard
  }

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "market_value_adjustments" do
    field :adjustment_type, :string, default: "increment"
    field :amount, :decimal
    field :customer_number, :string
    field :gender, :string
    field :delete, :boolean, virtual: true
    belongs_to :effective_date, EffectiveDate
    belongs_to :yard, Yard
    many_to_many :lot_status_codes, LotStatusCode, join_through: "adjustments_lot_status_codes"

    timestamps()
  end

  def changeset(market_value_adjustment, attrs \\ %{}) do
    cast(market_value_adjustment, attrs, [
      :adjustment_type,
      :amount,
      :customer_number,
      :gender,
      :effective_date_id,
      :yard_id,
      :delete
    ])
    |> cast_assoc(:lot_status_codes)
  end
end
