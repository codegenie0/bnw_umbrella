defmodule CattlePurchase.Seller do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{State, PurchaseSeller}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "sellers" do
    field :producer, :string
    field :seller_location, :string
    field :origin_code, :string
    field :description, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :active, :boolean, default: false
    belongs_to :state, State
    has_one :purchase_seller, PurchaseSeller
    has_one :purchase, through: [:purchase_seller, :purchase]

    timestamps()
  end

  @required ~w(state_id producer seller_location)a
  @optional ~w(description active origin_code latitude longitude)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> foreign_key_constraint(:state_id)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
