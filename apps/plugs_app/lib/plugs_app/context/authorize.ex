defmodule PlugsApp.Authorize do

  alias Accounts.User
  alias PlugsApp.Users

  def list_pages(user, apps) do
    {admin, _} = Users.has_roll(user.id, "admin")
    app = Enum.find(apps, &(&1.name == "Plugs"))

    cond do
      admin ->
        [app]
      true ->
        new_pages = []

        new_pages = new_pages ++
        if authorize(user, "fourteen_day_usage") != "" do
          [ Enum.find(app.pages, &(&1.name == "14 Day Usage")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "ab_packer") != "" do
          [ Enum.find(app.pages, &(&1.name == "AB Packer Pricing")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "cih") != "" do
          [ Enum.find(app.pages, &(&1.name == "CIH")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "vehicle_miles") != "" do
          [ Enum.find(app.pages, &(&1.name == "Company Vehicle Miles")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "dry_matter_sample") != "" do
          [ Enum.find(app.pages, &(&1.name == "Dry Matter Sample")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "fuel_usage") != "" do
          [ Enum.find(app.pages, &(&1.name == "Fuel Usage")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "mpc_comparisons") != "" do
          [ Enum.find(app.pages, &(&1.name == "MPC Comparisons")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "nbx_trucking") != "" do
          [ Enum.find(app.pages, &(&1.name == "NBX Trucking")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "ocb") != "" do
          [ Enum.find(app.pages, &(&1.name == "OCB")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "outside_billing") != "" do
          [ Enum.find(app.pages, &(&1.name == "Outside Billing")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "proj_breakeven") != "" do
          [ Enum.find(app.pages, &(&1.name == "Projected Breakeven")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "profit_center") != "" do
          [ Enum.find(app.pages, &(&1.name == "Turnkey Profit Center Key")) ]
        else
          []
        end

        new_pages = new_pages ++
        if authorize(user, "tyson_packer") != "" do
          [ Enum.find(app.pages, &(&1.name == "Tyson Packer Pricing")) ]
        else
          []
        end

        new_pages = new_pages ++
        if length(Users.list_secondary_roles(user.id)) > 0 do
          [ Enum.find(app.pages, &(&1.name == "Users"))]
        else
          []
        end

        if length(new_pages) > 0 do
          [Map.put(app, :pages, new_pages)]
        else
          []
        end
    end
  end

  def authorize(%User{} = user, page) do
    {access, level}  = Users.has_roll(user.id, page)
    {admin, _}       = Users.has_roll(user.id, "admin")
    cond do
      admin || user.it_admin -> "admin"
      access -> level
      length(Users.list_secondary_roles(user.id)) > 0 && page == "users" -> "view"
      true -> ""
    end
  end

end
