defmodule CattlePurchase.Sex do
  use Ecto.Schema
  import Ecto.Changeset
  alias CattlePurchase.AnimalSexOrder

  prefix = "bnw_dashboard_cattle_purchase"

  prefix =
    case Application.get_env(:cattle_purchase, :env) do
      :dev -> prefix <> "_dev"
      :test -> prefix <> "_test"
      _ -> prefix
    end

  @schema_prefix prefix

  schema "sexes" do
    field :name, :string
    field :code, :string
    has_one :animal_sex_order, AnimalSexOrder, on_replace: :delete

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(code)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
  end
end
