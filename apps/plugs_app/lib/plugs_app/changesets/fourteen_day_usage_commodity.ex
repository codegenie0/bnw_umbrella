defmodule PlugsApp.FourteenDayUsageCommodity do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "fourteen_day_usage_commodity" do
    field :yard,             :integer
    field :commodity_number, :integer
    field :commodity_name,   :string
    field :part_of_ration,   :boolean

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :yard,
          :commodity_number,
          :commodity_name,
          :part_of_ration,
        ])
    |> validate_required([:commodity_number, :yard])
    |> validate_required([:commodity_name, :yard])
    |> validate_yard()
    |> unique_constraint([:commodity_number, :yard], name: :usage_commodity_number_unique_key)
    |> unique_constraint([:commodity_name, :yard], name: :usage_commodity_name_unique_key)
  end

  def validate_yard(changeset) do
    {_, yard} = fetch_field(changeset, :yard)

    if is_nil(yard) || yard == 0 do
      add_error(changeset, :commodity_number, "No yard selected")
    else
      changeset
    end
  end
end
