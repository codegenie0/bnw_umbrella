defmodule CattlePurchase.Sex do
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

  schema "sexes" do
    field :name, :string
    field :description, :string
    field :order, :integer
    field :active, :boolean, default: false
    has_many(:purchases, Purchase)


    timestamps()
  end

  @required ~w(name order)a
  @optional ~w(description active)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
    |> unique_constraint(:name)
    |> unique_constraint(:order)
  end

  def new_changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
  end
end
