defmodule CattlePurchase.CommissionPayee do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.Commission

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "commission_payees" do
    field :name, :string
    field :description, :string
    field :active, :boolean, default: false
    has_many(:commissions, Commission)

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(active description)a
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
