defmodule OcbReportPlugs.Plug do
  use Ecto.Schema
  import Ecto.Changeset

  prefix = "bnw_dashboard_ocb_report_plugs"
  prefix = case Application.get_env(:ocb_report_plugs, :env) do
    :dev -> prefix <> "_dev"
    :test -> prefix <> "_test"
    _ -> prefix
  end

  @schema_prefix prefix

  schema "plugs" do
    field :carcass_low, :integer
    field :carcass_high, :integer
    field :calculated_yield_grade, :decimal
    field :quality_grade, :string
    field :add_30, :integer
    field :add_ag, :integer
  end

  def changeset(plug, attrs \\ %{}) do
    plug
    |> cast(attrs, [
      :carcass_low,
      :carcass_high,
      :calculated_yield_grade,
      :quality_grade,
      :add_30,
      :add_ag])
    |> validate_required([
      :carcass_low,
      :carcass_high,
      :calculated_yield_grade,
      :quality_grade,
      :add_30,
      :add_ag])
  end


end
