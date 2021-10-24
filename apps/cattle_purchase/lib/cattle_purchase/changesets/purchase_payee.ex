defmodule CattlePurchase.PurchasePayee do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{Purchase, Payee}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_payees" do
    belongs_to(:purchase, Purchase)

    belongs_to(:payee, Payee,
      references: :id,
      type: :string
    )

    timestamps()
  end

  @required ~w(purchase_id payee_id)a
  @allowed @required

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:purchase, name: :purchase_payee_unique_index)
    |> foreign_key_constraint(:purchase_id)
    |> foreign_key_constraint(:payee_id)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, [])
  end
end
