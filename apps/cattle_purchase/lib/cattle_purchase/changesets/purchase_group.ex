defmodule CattlePurchase.PurchaseGroup do
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

  schema "purchase_groups" do
    field :name, :string
    field :include_in_partnership, :boolean, default: false
    field :include_in_kills, :boolean, default: false

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(include_in_partnership include_in_kills)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
  end
end
