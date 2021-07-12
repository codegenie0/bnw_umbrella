defmodule CattlePurchase.PurchaseTypePurchaseTypeFilter do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_type_purchase_type_filters" do
    belongs_to(:purchase_type, CattlePurchase.PurchaseType)
    belongs_to(:purchase_type_filter, CattlePurchase.PurchaseTypeFilter)

    timestamps()
  end

  @required ~w(purchase_type_id purchase_type_filter_id)a
  @allowed @required

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:purchase_type_filter, name: :purchase_type_filters_unique_index)
  end

  def changeset_for_purchase_types(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
