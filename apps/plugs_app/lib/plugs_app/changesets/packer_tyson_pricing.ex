defmodule PlugsApp.PackerTysonPricing do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_plugs_app"
  prefix = case Application.get_env(:plugs_app, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "packer_tyson_pricing" do
      field :mpc_week_end_date,    :date
      field :usda,                 :decimal
      field :reg_tyson_base_price, :decimal
      field :reg_plt_yld_percent,  :decimal
      field :reg_prime,            :decimal
      field :reg_cab,              :decimal
      field :reg_select,           :decimal
      field :reg_no_roll,          :decimal
      field :reg_low_quality,      :decimal
      field :reg_heiferette,       :decimal
      field :reg_yg1,              :decimal
      field :reg_yg2,              :decimal
      field :reg_yg4,              :decimal
      field :reg_yg5,              :decimal
      field :reg_dn_549,           :decimal
      field :reg_up_1050,          :decimal
      field :hol_base_price,       :decimal
      field :hol_plt_yld_percent,  :decimal
      field :hol_prime,            :decimal
      field :hol_select,           :decimal
      field :hol_no_roll,          :decimal
      field :hol_low_quality,      :decimal
      field :hol_yg1,              :decimal
      field :hol_yg2,              :decimal
      field :hol_yg4,              :decimal
      field :hol_yg5,              :decimal
      field :hol_dn_550,           :decimal
      field :hol_up_1050,          :decimal

      timestamps()
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
      :mpc_week_end_date,
      :usda,
      :reg_tyson_base_price,
      :reg_plt_yld_percent,
      :reg_prime,
      :reg_cab,
      :reg_select,
      :reg_no_roll,
      :reg_low_quality,
      :reg_heiferette,
      :reg_yg1,
      :reg_yg2,
      :reg_yg4,
      :reg_yg5,
      :reg_dn_549,
      :reg_up_1050,
      :hol_base_price,
      :hol_plt_yld_percent,
      :hol_prime,
      :hol_select,
      :hol_no_roll,
      :hol_low_quality,
      :hol_yg1,
      :hol_yg2,
      :hol_yg4,
      :hol_yg5,
      :hol_dn_550,
      :hol_up_1050,
        ])
    |> unique_constraint([:mpc_week_end_date], name: :packer_tyson_pricing_unique_constraint)
  end
end
