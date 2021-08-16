defmodule PlugsApp.Pages do
  def list_pages() do
    [
      %{name: "14 Day Usage",                 url: "/plugs/fourteen_day_usage"},
      %{name: "AB Packer Pricing",            url: "/plugs/packer_ab_pricing"},
      %{name: "CIH",                          url: "/plugs/cih"},
      %{name: "Company Vehicle Miles",        url: "/plugs/company_vehicles"},
      %{name: "Dry Matter Sample",            url: "/plugs/dry_matter_sample"},
      %{name: "Fuel Usage",                   url: "/plugs/fuel_usage"},
      %{name: "MPC Comparisons",              url: "/plugs/mpc_comparisons"},
      %{name: "NBX Trucking",                 url: "/plugs/nbx_trucking"},
      %{name: "OCB",                          url: "/plugs/ocb"},
      %{name: "Outside Billing",              url: "/plugs/outside_billing"},
      %{name: "Projected Breakeven",          url: "/plugs/projected_breakeven"},
      %{name: "Turnkey Profit Center Key",    url: "/plugs/profit_center_key"},
      %{name: "Tyson Packer Pricing",         url: "/plugs/packer_tyson_pricing"},
      %{name: "Users",                        url: "/plugs/users"},
      %{name: "Help",                         url: "/plugs/help"}
    ]
  end
end
