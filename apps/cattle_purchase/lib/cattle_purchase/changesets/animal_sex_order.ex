defmodule CattlePurchase.AnimalSexOrder do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.Sex

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "animal_sex_orders" do
    field :order, :integer, default: 0
    belongs_to :sex, Sex

    timestamps()
  end

  @required ~w(sex_id)a
  @optional ~w(order)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
  end
end
