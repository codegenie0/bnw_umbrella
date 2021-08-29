defmodule CattlePurchase.CattleReceiving do
  use Ecto.Schema
  import Ecto.Changeset

  alias CattlePurchase.{
    Sex,
    Shipment,
    User
  }

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "cattle_receivings" do
    field :date_received, :date
    field :number_received, :integer
    field :pay_weight, :integer
    field :comment, :string
    field :lot_number, :string
    field :wcc_notification, :boolean, default: false
    field :receive_override, :boolean, default: false
    field :flow_to_purchase_sheet, :boolean, default: false
    field :verified, :boolean, default: false
    field :off_truck_weight, :integer

    belongs_to :user, User
    belongs_to :sex, Sex
    belongs_to :shipment, Shipment

    timestamps()
  end

  @required ~w(date_received number_received pay_weight lot_number
                user_id shipment_id off_truck_weight
              )a
  @optional ~w(comment wcc_notification receive_override flow_to_purchase_sheet sex_id verified)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> foreign_key_constraint(:sex_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:shipment_id)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
