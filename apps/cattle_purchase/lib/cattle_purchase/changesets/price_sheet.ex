defmodule CattlePurchase.PriceSheet do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.PriceSheetDetail


  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "price_sheets" do
    field :price_date, :date
    field :comment, :string

    has_many(:price_sheet_details, PriceSheetDetail)


    timestamps()
  end

  @allowed ~w(price_date comment)a
  @required ~w(price_date)a

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
