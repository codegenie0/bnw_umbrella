defmodule CattlePurchase.DestinationGroup do
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

  schema "destination_groups" do
    field :name, :string
    field :lft, :integer
    field :rgt, :integer

    timestamps()
  end

  @required ~w(name)a
  @optional ~w(lft rgt)a
  @allowed @required ++ @optional

  def changeset(%__MODULE__{} = model, attrs \\ %{}) do
    model
    |> cast(attrs, @allowed)
    |> validate_required(@required)
  end
end
