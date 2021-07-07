defmodule CattlePurchase.PurchaseTypeFilter do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "purchase_type_filters" do
    field :name, :string
    field :default_group, :boolean, default: false
    many_to_many(:purchase_types, CattlePurchase.PurchaseType , join_through: "purchase_type_purchase_type_filters")

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(default_group)a
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
