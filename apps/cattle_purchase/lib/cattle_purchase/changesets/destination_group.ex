defmodule CattlePurchase.DestinationGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{Purchase, Shipment}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "destination_groups" do
    field :name, :string
    has_many(:destinations, CattlePurchase.DestinationGroup)
    has_many(:purchases, Purchase)
    has_many(:shipments, Shipment)
    has_many(:future_purchases, Purchase, foreign_key: :future_destination_group_id)

    timestamps()
  end

  @required ~w(name)a
  @allowed @required

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
