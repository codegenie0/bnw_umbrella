defmodule CattlePurchase.DownPayment do
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

  schema "down payments" do
    field :description, :string
    field :amount, :decimal
    field :date_paid, :date
    field :locked, :boolean, default: false
    belongs_to(:purchase, Purchase)

    timestamps()
  end

  @required ~w(amount date_paid purchase_id)a
  @optional ~w(description locked)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> foreign_key_constraint(:purchase_id)

  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
