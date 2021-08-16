defmodule PlugsApp.CompanyVehicleMile do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "company_vehicle_miles" do
    field :entry_date,  :date
    field :fy,          :integer
    field :yard,        :integer
    field :driver_name, :string
    field :beginning,   :integer
    field :ending,      :integer
    field :miles,       :integer
    field :trip_miles,  :integer

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :entry_date,
          :fy,
          :yard,
          :driver_name,
          :beginning,
          :ending,
          :miles,
          :trip_miles,
        ])
    |> validate_required([:fy, :yard])
    |> calculate_miles()
    |> unique_constraint([:entry_date, :fy, :yard, :driver_name], name: :company_vehicle_miles_unique_key)
  end

  defp calculate_miles(changeset) do
    {_, beginning} = fetch_field(changeset, :beginning)
    {_, ending}    = fetch_field(changeset, :ending)

    cond do
      !is_nil(beginning) && !is_nil(ending) ->
        change(changeset, %{miles: ending - beginning})
      !is_nil(ending) ->
        change(changeset, %{miles: ending})
      true ->
        change(changeset, %{miles: 0})
    end
  end
end
