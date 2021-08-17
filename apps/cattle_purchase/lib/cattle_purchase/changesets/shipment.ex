defmodule CattlePurchase.Shipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias CattlePurchase.{
    Sex,
    DestinationGroup,
    Purchase,
    CattleReceiving,
    Repo
  }

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "shipments" do
    field :destination_group_name, :string
    field :estimated_ship_date, :date
    field :head_count, :integer
    field :firm, :boolean, default: false
    field :complete, :boolean, default: false
    field :projected_out_date, :date
    field :expected_lots, :integer
    belongs_to :sex, Sex
    belongs_to :destination_group, DestinationGroup
    belongs_to :purchase, Purchase
    has_many(:cattle_receivings, CattleReceiving)

    timestamps()
  end

  @required ~w(estimated_ship_date head_count projected_out_date destination_group_id
                sex_id purchase_id
              )a
  @optional ~w(expected_lots firm complete destination_group_name)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    if model.id == nil do
      model
      |> cast(attrs, @allowed)
      |> validate_required(@required)
      |> foreign_key_constraint(:sex_id)
      |> foreign_key_constraint(:destination_group_id)
      |> foreign_key_constraint(:purchase_id)
      |> validate_head_count(attrs["head_count"], attrs["purchase_id"])
    else
      model
      |> cast(attrs, @allowed)
      |> validate_required(@required)
      |> foreign_key_constraint(:sex_id)
      |> foreign_key_constraint(:destination_group_id)
      |> foreign_key_constraint(:purchase_id)
    end
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end

  def validate_head_count(cs, head_count, purchase_id) do
    head_count_empty = String.trim(head_count) == ""
    purchase_id_empty = String.trim(purchase_id) == ""

    if !head_count_empty && !purchase_id_empty do
      purchase = Repo.get(Purchase, purchase_id |> String.to_integer())

      if head_count |> String.to_integer() > purchase.head_count do
        add_error(cs, :head_count, "Must be less or equal to the head_count of purchases")
      else
        cs
      end
    else
      cs
    end
  end
end
