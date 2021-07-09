defmodule CattlePurchase.WeightCategory do
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
  schema "weight_categories" do
    field :start_weight, :integer
    field :end_weight, :integer

    timestamps()
  end

  @required ~w(start_weight end_weight)a
  @allowed @required

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
