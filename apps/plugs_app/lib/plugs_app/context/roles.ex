defmodule PlugsApp.Roles do
  def list_main_roles() do
    [
      %{name: "admin", external_name: "Admin"}
    ]
  end

  def list_secondary_roles() do
    [
      %{name: "fourteen_day_usage", external_name: "14 Day Usage"},
      %{name: "ab_packer",          external_name: "AB Packer Pricing"},
      %{name: "cih",                external_name: "CIH"},
      %{name: "vehicle_miles",      external_name: "Company Vehicle Miles"},
      %{name: "dry_matter_sample",  external_name: "Dry Matter Sample"},
      %{name: "fuel_usage",         external_name: "Fuel Usage"},
      %{name: "mpc_comparisons",    external_name: "MPC Comparisons"},
      %{name: "nbx_trucking",       external_name: "NBX Trucking"},
      %{name: "ocb",                external_name: "OCB"},
      %{name: "outside_billing",    external_name: "Outside Billing"},
      %{name: "proj_breakeven",     external_name: "Projected Breakeven"},
      %{name: "profit_center",      external_name: "Turnkey Profit Center Key"},
      %{name: "tyson_packer",       external_name: "Tyson Packer Pricing"},
    ]
  end
end
