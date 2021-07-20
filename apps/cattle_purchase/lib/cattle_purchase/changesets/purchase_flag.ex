defmodule CattlePurchase.PurchaseFlag do
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

  schema "purchase_flags" do
    field :name, :string
    many_to_many(:purchases, Purchase , join_through: "purchase_purchase_flags", on_delete: :delete_all)


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
