defmodule CattlePurchase.PriceSheet do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{PriceSheetDetail, Repo}

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

    has_many(:price_sheet_details, PriceSheetDetail, on_replace: :delete, on_delete: :delete_all)

    timestamps()
  end

  @allowed ~w(price_date comment)a
  @required ~w(price_date)a

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model =
      if(model.id != nil,
        do: model |> Repo.preload(:price_sheet_details),
        else: model
      )

    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:price_date)
    |> cast_assoc(:price_sheet_details, with: &PriceSheetDetail.new_changeset/2)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
