defmodule PlugsApp.PackerAbPricing do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "packer_ab_pricing" do
      field :mpc_week_end_date, :date
      field :usda,              :decimal
      field :c_fax_6_state,     :decimal
      field :reg_ab_base_price, :decimal
      field :usda_spread,       :decimal
      field :plt_yld_percent,   :decimal
      field :prime,             :decimal
      field :double_r,          :decimal
      field :choice_plus,       :decimal
      field :choice_threshold,  :decimal
      field :standard,          :decimal
      field :commercial,        :decimal
      field :no_roll,           :decimal
      field :low_quality,       :decimal
      field :yg1,               :decimal
      field :yg2,               :decimal
      field :yg4,               :decimal
      field :yg5,               :decimal
      field :underweight,       :decimal
      field :overweight,        :decimal
      field :plus_30_months,    :decimal
      field :plus_30_2_percent, :decimal

      timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
          :mpc_week_end_date,
          :usda,
          :c_fax_6_state,
          :reg_ab_base_price,
          :usda_spread,
          :plt_yld_percent,
          :prime,
          :double_r,
          :choice_plus,
          :choice_threshold,
          :standard,
          :commercial,
          :no_roll,
          :low_quality,
          :yg1,
          :yg2,
          :yg4,
          :yg5,
          :underweight,
          :overweight,
          :plus_30_months,
          :plus_30_2_percent,
        ])
    |> unique_constraint([:mpc_week_end_date], name: :packer_ab_pricing_unique_constraint)
  end
end
