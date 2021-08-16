defmodule PlugsApp.DryMatterSample do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "dry_matter_samples" do
    field :yard,        :integer
    field :item,        :integer
    field :sample_date, :date
    field :pan,         :decimal
    field :wet,         :decimal
    field :dry,         :decimal
    field :target_dm,   :decimal

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :yard,
          :item,
          :sample_date,
          :pan,
          :wet,
          :dry,
          :target_dm,
        ])
    |> validate_required([:yard, :item])
    |> unique_constraint(
      [
        :yard,
        :item,
        :sample_date,
        :pan,
        :wet,
        :dry,
        :target_dm,
      ],
      name: :dms_unique_key)
  end
end
