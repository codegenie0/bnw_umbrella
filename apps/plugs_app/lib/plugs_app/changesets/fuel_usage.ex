defmodule PlugsApp.FuelUsage do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "fuel_usage" do
    field :start_date,   :date
    field :yard,         :integer
    field :type,         :integer
    field :department,   :integer
    field :gallons,      :decimal
    field :amount,       :decimal
    field :price_gallon, :decimal

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :start_date,
          :yard,
          :type,
          :department,
          :gallons,
          :amount,
          :price_gallon,
        ])
    |> validate_required([:yard, :type, :department])
    |> calculate_price_gallon()
    |> unique_constraint([:start_date, :yard, :type, :department], name: :fuel_usage_uniqu_constraint)
  end

  defp calculate_price_gallon(changeset) do
    {_, amount} = fetch_field(changeset, :amount)
    {_, gallons} = fetch_field(changeset, :gallons)

    if !is_nil(amount) && !is_nil(gallons) do
      if Decimal.equal?(amount, 0) || Decimal.equal?(gallons, 0) do
        change(changeset, %{price_gallon: 0})
      else
        change(changeset, %{price_gallon: Decimal.div(amount, gallons)})
      end
    else
      changeset
    end
  end
end
