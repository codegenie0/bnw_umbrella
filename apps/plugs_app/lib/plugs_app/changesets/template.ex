defmodule PlugsApp.Template do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "template" do
    field :co_month,                :date
    field :yard,                    :integer
    field :lot,                     :string
    field :proj_dmc,                :decimal
    field :proj_other_costs,        :decimal
    field :proj_rations_costs,      :decimal
    field :proj_death_loss_percent, :decimal
    field :op_percent,              :decimal
    field :proj_adg,                :decimal
    field :fat_freight,             :decimal
    field :proj_cog_w_interest,     :decimal
    field :proj_be_wo_interest,     :decimal
    field :proj_be,                 :decimal
    field :cnb_purchase_price,      :decimal
    field :yard_lot,                :string

    timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :co_month,
          :yard,
          :lot,
          :proj_dmc,
          :proj_other_costs,
          :proj_rations_costs,
          :proj_death_loss_percent,
          :op_percent,
          :proj_adg,
          :fat_freight,
          :proj_cog_w_interest,
          :proj_be_wo_interest,
          :proj_be,
          :cnb_purchase_price,
          :yard_lot,
        ])
    |> validate_required(:yard)
    |> unique_constraint([:co_month, :yard, :lot], name: :template_unique_constraint)
  end
end
