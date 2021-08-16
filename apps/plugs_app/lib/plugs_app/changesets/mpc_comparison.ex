defmodule PlugsApp.MpcComparison do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "mpc_comparison" do
    field :week_end_date, :date
    field :monday_date,   :date
    field :c_fax_price,   :decimal
    field :c_fax_notes,   :string
    field :usda_price,    :decimal
    field :usda_notes,    :string
    field :tt_price,      :decimal
    field :tt_notes,      :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :week_end_date,
          :monday_date,
          :c_fax_price,
          :c_fax_notes,
          :usda_price,
          :usda_notes,
          :tt_price,
          :tt_notes,
        ])
    |> monday_in_the_week()
    |> unique_constraint([:monday_date], name: :mpc_comparison_unique_constraint)
  end

  def monday_in_the_week(changeset) do
    {_, end_date} = fetch_field(changeset, :week_end_date)

    if !is_nil(end_date) do
      from_monday = Date.day_of_week(end_date) - 1
      monday_date = end_date
      |> Date.to_gregorian_days()
      |> Kernel.-(from_monday)
      |> Date.from_gregorian_days()

      change(changeset, %{monday_date: monday_date})
    else
      changeset
    end
  end
end
