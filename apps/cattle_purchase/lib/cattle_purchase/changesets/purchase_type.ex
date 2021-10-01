defmodule CattlePurchase.PurchaseType do
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

  schema "purchase_types" do
    field :name, :string
    field :active, :boolean, default: false
    field :purchase_detail, :boolean, default: true
    field :seller, :boolean, default: true
    field :payee, :boolean, default: false
    field :commission, :boolean, default: false
    field :down_payments, :boolean, default: false
    field :contracts, :boolean, default: false
    field :futures_pricing, :boolean, default: false
    field :exclude, :boolean, default: false
    has_many(:purchases, Purchase)

    many_to_many(:purchase_type_filters, CattlePurchase.PurchaseTypeFilter,
      join_through: "purchase_type_purchase_type_filters",
      on_delete: :delete_all
    )

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(active exclude purchase_detail seller
    payee commission down_payments contracts futures_pricing)a
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
