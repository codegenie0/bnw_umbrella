defmodule CattlePurchase.Commission do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.{Purchase, CommissionPayee}

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "commissions" do
    field :commission_per_hundred, :decimal

    belongs_to(:purchase, Purchase)
    belongs_to(:commission_payee, CommissionPayee)

    timestamps()
  end

  @required ~w(commission_per_hundred purchase_id commission_payee_id )a
  @allowed @required

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, [:commission_per_hundred, :commission_payee_id])
  end
end
