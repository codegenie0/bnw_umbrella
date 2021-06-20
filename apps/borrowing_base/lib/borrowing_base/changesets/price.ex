defmodule BorrowingBase.Price do
  use Ecto.Schema
  import Ecto.Changeset

  alias BorrowingBase.WeightGroup

  prefix = "bnw_dashboard_borrowing_base"
  prefix = case Application.get_env(:borrowing_base, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end
  @schema_prefix prefix

  schema "prices" do
    field :gender, :string
    field :amount, :decimal
    belongs_to :weight_group, WeightGroup

    timestamps()
  end

  def changeset(price, attrs \\ %{}) do
    price
    |> cast(attrs, [:amount, :gender, :weight_group_id])
    |> validate_required([:amount, :gender])
    |> unique_constraint(:amount, name: :prices_unique_index)
  end
end
