defmodule CattlePurchase.PurchasePurchaseFlag do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{Purchase, PurchaseFlag}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_purchase_flags" do
    belongs_to(:purchase, Purchase)
    belongs_to(:purchase_flag, PurchaseFlag)

    timestamps()
  end

  @required ~w(purchase_id purchase_flag_id)a
  @allowed @required

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:purchase, name: :purchase_purchase_flag_unique_index)
    |> foreign_key_constraint(:purchase_id)
    |> foreign_key_constraint(:purchase_flag_id)

  end

  def changeset_for_purchase_flags(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
