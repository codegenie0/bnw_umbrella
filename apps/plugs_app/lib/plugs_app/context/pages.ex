defmodule PlugsApp.Pages do
  def list_pages() do
    [
      %{name: "Projected Breakeven",          url: "/plugs/projected_breakeven"},
      %{name: "MPC Comparisons",              url: "/plugs/mpc_comparisons"},
      %{name: "Tyson Packer Pricing",         url: "/plugs/packer_tyson_pricing"},
      %{name: "AB Packer Pricing",            url: "/plugs/packer_ab_pricing"},
      %{name: "NBX Trucking",                 url: "/plugs/nbx_trucking"},
      %{name: "Fuel Usage",                   url: "/plugs/fuel_usage"},
      %{name: "Turnkey Profit Center Key",    url: "/plugs/profit_center_key"},
      %{name: "Company Vehicle Miles",        url: "/plugs/company_vehicles"},
      %{name: "Users",                        url: "/plugs/users"},
      %{name: "Help",                         url: "/plugs/help"}
    ]
  end
end
