defmodule PlugsApp.Roles do
  def list_main_roles() do
    [
      %{name: "admin", external_name: "Admin"},
      %{name: "user",  external_name: "User"}
    ]
  end

  def list_secondary_roles() do
    [
      %{name: "proj_breakeven",  external_name: "Projected Breakeven"},
      %{name: "mpc_comparisons", external_name: "MPC Comparisons"},
      %{name: "tyson_packer",    external_name: "Tyson Packer Pricing"},
      %{name: "ab_packer",       external_name: "AB Packer Pricing"},
      %{name: "nbx_trucking",    external_name: "NBX Trucking"},
      %{name: "fuel_usage",      external_name: "Fuel Usage"},
      %{name: "profit_center",   external_name: "Turnkey Profit Center Key"},
      %{name: "vehicle_miles",   external_name: "Company Vehicle Miles"}
    ]
  end
end
