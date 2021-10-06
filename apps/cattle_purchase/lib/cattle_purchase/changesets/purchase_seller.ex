defmodule CattlePurchase.PurchaseSeller do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{Purchase, Seller}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_sellers" do
    belongs_to(:purchase, Purchase)
    belongs_to(:seller, Seller)

    timestamps()
  end

  @required ~w(purchase_id seller_id)a
  @allowed @required

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:purchase, name: :purchase_seller_unique_index)
    |> foreign_key_constraint(:purchase_id)
    |> foreign_key_constraint(:seller_id)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, [])
  end
end
