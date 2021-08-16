defmodule BnwDashboardWeb.PlugsApp.FourteenDayUsage.FourteenDayUsageLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.Helpers.{
    ModalComponent,
    TableLive,
    SearchLive,
    ChangeReportComponent
  }

  alias BnwDashboardWeb.PlugsApp.FourteenDayUsage.ChangeYardComponent
  alias BnwDashboardWeb.PlugsApp.FourteenDayUsage.ChangeCommodityComponent

  alias PlugsApp.{
    FourteenDayUsages,
    FourteenDayUsageYards,
    FourteenDayUsageCommodities,
    Authorize,
    Reports,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "fourteen_day_usage")
    else
      ""
    end
  end

  defp authenticate(socket) do
    case get_role(socket) do
      "admin" -> true
      "edit"  -> true
      "view"  -> true
      _       -> false
    end
  end

  defp fetch_permissions(socket) do
    role = get_role(socket)
    it_admin = socket.assigns.current_user.it_admin
    is_admin = role == "admin"
    is_edit  = role == "admin" or role == "edit"
    assign(socket, it_admin: it_admin, is_admin: is_admin, is_edit: is_edit)
  end

  defp init_args(socket) do
    %{
      selected_commodity: selected_commodity,
      commodities: commodities
    } = socket.assigns
    args = [
      %{type: :disp_only, special: :drop_down, name: :commodity,        display_name: "Commodity", selected: selected_commodity, list: commodities},
      %{type: :number,    special: :int,       name: :inventory_amount, display_name: "Inventory Amount", step: 1},
      %{type: :number,    special: :int,       name: :usage_pounds,     display_name: "Usage Pounds",     step: 1},
      %{type: :number,    special: :int,       name: :receiving_pounds, display_name: "Receiving Pounds", step: 1},
    ]

    assign(socket, args: args)
  end

  defp fetch_commodities(plug) do
    commodity = Map.get(plug, :commodity, 0)
    |> FourteenDayUsageCommodities.get_plug()
    Map.put(plug, :commodity, commodity)
  end

  defp fetch_plugs(socket) do
    %{selected_yard: selected_yard} = socket.assigns
    %{
      page: page,
      per_page: per_page,
      search: search,
      selected_search_col: search_col
    } = socket.assigns
    pre_plugs = Map.get(socket.assigns, :plugs, [])

    plugs =
      FourteenDayUsages.list_plugs(selected_yard, page, per_page, search_col, search)
      |> Enum.map(&(fetch_commodities(&1)))
      |> Enum.map(&(FourteenDayUsages.change_plug(&1)))
    assign(socket, plugs: pre_plugs ++ plugs)
  end

  defp fetch_extra(socket) do
    %{selected_yard: selected_yard} = socket.assigns
    yards = FourteenDayUsageYards.list_plugs()
    selected_yard =
    if is_nil(selected_yard) do
      if Enum.count(yards) > 0 do
        Enum.at(yards, 0)[:value]
      else
        0
      end
    else
      selected_yard
    end
    commodities = FourteenDayUsageCommodities.list_plugs(selected_yard)
    assign(socket,
      selected_yard: selected_yard,
      yards: yards,
      commodities: commodities)
  end

  defp fetch_plug_extra(socket) do
    %{selected_yard: selected_yard} = socket.assigns
    plug_yards = FourteenDayUsageYards.list_all_plugs()
    plug_commodities = FourteenDayUsageCommodities.list_all_plugs(selected_yard)
    assign(socket, plug_yards: plug_yards, plug_commodities: plug_commodities)
  end

  defp init_reports(socket) do
    %{plug: plug} = socket.assigns
    reports = Reports.list_reports(plug)

    assign(socket, can_show_reports: Enum.count(reports) > 0, reports: reports)
  end

  @impl true
  def mount(_params, session, socket) do
    page = 1
    per_page = 20
    socket =
      assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Plugs 14 Day Usage",
                app: "Plugs",
                add_more: false,
                show_yards: true,
                selected_yard: nil,
                selected_commodity: 1,
                yards: nil,
                commodities: nil,
                modal: nil,
                update_action: "replace",
                page: page,
                plug: "14_day_usage",
                selected_search_col: :commodity,
                search: "",
                per_page: per_page)
      |> fetch_extra()
      |> fetch_plugs()
      |> fetch_permissions()
      |> init_args()
      |> init_reports()

    if connected?(socket) do
      FourteenDayUsages.subscribe()
      FourteenDayUsageYards.subscribe()
      FourteenDayUsageCommodities.subscribe()
      Reports.subscribe()
      Users.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage_commodity, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage_commodity, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage_yard, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage_yard, :deleted], _}, socket) do
    socket = fetch_extra(socket)
    |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage, :created_or_updated_add_more], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage, :created_or_updated], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fourteen_day_usage, :deleted], _}, socket) do
    socket = assign(socket, page: 1, plugs: [])
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :created_or_updated], _}, socket) do
    socket = init_reports(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:report, :deleted], _}, socket) do
    socket = init_reports(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:user, :updated], _plug}, socket) do
    case authenticate(socket) do
      true -> {:noreply, fetch_permissions(socket)}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_yards", _, socket) do
    socket = assign(socket,
      modal: :change_yard,
      modal_title: "Manage Yards")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_commodities", _, socket) do
    socket = assign(socket,
      modal: :change_commodity,
      modal_title: "Manage Commodities")
      |> fetch_plug_extra()
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    %{
      commodities: commodities
    } = socket.assigns
    commodity = Enum.find(commodities, fn x-> x[:key] == cur.data.commodity end)[:value]

    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      modal_title: "Edit 14 Day Usage",
      selected_commodity: commodity)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      FourteenDayUsages.new_plug()
      |> FourteenDayUsages.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New 14 Day Usage",
      selected_commodity: 1)
      |> init_args()
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set_yard", %{"yard" => yard}, socket) do
    socket = assign(socket, selected_yard: String.to_integer(yard), plugs: [])
    |> fetch_extra()
    |> fetch_plugs()
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    FourteenDayUsages.delete_plug(cur.data)
    {:noreply, socket}
  end

  def handle_event("save", %{"fourteen_day_usage" => plug}, socket) do
    %{
      changeset: changeset,
      add_more: add_more,
      selected_yard: selected_yard
    } = socket.assigns
    plug = Map.put(plug, "yard", selected_yard)

    changeset = FourteenDayUsages.validate(changeset.data, plug)
    if changeset.valid? do
      case FourteenDayUsages.create_or_update_plug(changeset.data, plug, add_more) do
        {:ok, _plug} ->
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("add_more", _, socket) do
    {:noreply, assign(socket, add_more: true)}
  end

  def handle_event("done", _, socket) do
    {:noreply, assign(socket, add_more: false)}
  end

  def handle_event("validate", %{"fourteen_day_usage" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = FourteenDayUsages.validate(changeset.data, plug)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("load_more", _, socket) do
    %{
      page: page
    } = socket.assigns
    page = page + 1
    socket = assign(socket, update_action: "append", page: page)

    {:noreply, fetch_plugs(socket)}
  end

  def handle_event("show_reports", _, socket) do
    {:noreply, assign(socket,
        modal: :show_reports,
        modal_title: "14 Day Usage Reports")}
  end

  def handle_event("search", %{"search" => params}, socket) do
    %{
      selected_search_col: prev_col,
      search: prev_search
    } = socket.assigns
    %{
      "search" => search,
      "search_col" => search_col
    } = params

    search_col = String.to_atom(search_col)

    search =
    if prev_col == search_col do
      search
    else
      ""
    end

    socket = assign(socket,
      selected_search_col: search_col,
      search: search
    )

    socket =
    if search_col &&
    (search != "" ||
      prev_search != "") do
      assign(socket, page: 1, plugs: [])
      |> fetch_plugs()
    else
      socket
    end
    {:noreply, socket}
  end
end
