defmodule CattlePurchase.PurchaseBuyer do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.Purchase


  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_buyers" do
    field :name, :string
    has_many(:purchases, Purchase, foreign_key: :buyer_id)


    timestamps()
  end

  @allowed ~w(name)a
  @required ~w(name)a

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
