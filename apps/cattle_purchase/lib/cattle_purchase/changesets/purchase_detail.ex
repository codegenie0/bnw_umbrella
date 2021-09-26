defmodule CattlePurchase.PurchaseDetail do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.Sex

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_details" do
    field :head_count, :integer
    field :average_weight, :integer
    field :price, :decimal
    field :projected_break_even, :decimal
    field :purchase_basis, :decimal
    field :futures_order_price, :decimal
    field :cash_price, :decimal
    field :projected_out_date, :date
    field :order_date, :date
    field :fill_date, :date
    belongs_to :sex, Sex
    timestamps()
  end

  @required ~w(head_count average_weight price projected_break_even projected_basis)a
  @optional ~w(futures_order_price cash_price projected_out_date order_date fill_date)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
