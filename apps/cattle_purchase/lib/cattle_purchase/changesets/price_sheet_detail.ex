defmodule CattlePurchase.PriceSheetDetail do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{PriceSheet, Sex, WeightCategory}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "price_sheet_details" do
    field :value, :decimal

    belongs_to :sex, Sex
    belongs_to :price_sheet, PriceSheet
    belongs_to :weight_category, WeightCategory

    timestamps()
  end

  @allowed ~w(value sex_id price_sheet_id weight_category_id)a
  @required ~w(sex_id price_sheet_id weight_category_id)a

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> foreign_key_constraint(:sex_id)
    |> foreign_key_constraint(:weight_category_id)
    |> foreign_key_constraint(:price_sheet_id)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
