defmodule PlugsApp.DryMatterSampleItem do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "dry_matter_samples_items" do
    field :yard, :integer
    field :item, :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :yard,
          :item,
        ])
    |> validate_required([:item, :yard])
    |> validate_yard()
    |> unique_constraint([:yard, :item], name: :dms_items_unique_key)
  end

  def validate_yard(changeset) do
    {_, yard} = fetch_field(changeset, :yard)

    if is_nil(yard) || yard == 0 do
      add_error(changeset, :item, "No yard selected")
    else
      changeset
    end
  end
end
