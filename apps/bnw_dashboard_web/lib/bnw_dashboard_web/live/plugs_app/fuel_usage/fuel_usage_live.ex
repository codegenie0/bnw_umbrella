defmodule BnwDashboardWeb.PlugsApp.FuelUsage.FuelUsageLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.FuelUsage.{
    ChangePlugComponent,
    ChangeDepartmentComponent,
    ChangeTypeComponent,
    ChangeYardComponent
  }
  alias PlugsApp.{
    FuelUsages,
    FuelUsageDepartments,
    FuelUsageTypes,
    FuelUsageYards,
    Authorize,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "fuel_usage")
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
    is_admin = role == "admin"
    is_edit  = role == "admin" or role == "edit"
    assign(socket, is_admin: is_admin, is_edit: is_edit)
  end

  defp fetch_plugs(socket) do
    plugs =
      FuelUsages.list_plugs()
      |> Enum.map(&(FuelUsages.change_plug(&1)))
    assign(socket, plugs: plugs)
  end

  defp fetch_extra(socket) do
    departments = FuelUsageDepartments.list_plugs()
    types       = FuelUsageTypes.list_plugs()
    yards       = FuelUsageYards.list_plugs()
    assign(socket,
      departments: departments,
      types: types,
      yards: yards
    )
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> assign(page_title: "BNW Dashboard · Plugs Fuel Usage",
                app: "Plugs",
                modal: nil)

    if connected?(socket) do
      FuelUsages.subscribe()
      FuelUsageDepartments.subscribe()
      FuelUsageTypes.subscribe()
      FuelUsageYards.subscribe()
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
  def handle_info({[:fuel_usage_department, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
    |> fetch_extra()
    |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_type, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
    |> fetch_extra()
    |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage_yard, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
    |> fetch_extra()
    |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:fuel_usage, :deleted], _}, socket) do
    socket = fetch_plugs(socket)
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
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    socket = assign(socket,
      changeset: cur,
      modal: :change_plug,
      selected_department: cur.data.department,
      selected_type:       cur.data.type,
      selected_yard:       cur.data.yard,
      modal_title: "Edit Fuel Usage")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      FuelUsages.new_plug()
      |> FuelUsages.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      selected_department: 1,
      selected_type:       1,
      selected_yard:       1,
      modal_title: "New Fuel Usage")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_department", _, socket) do
    changeset =
      FuelUsageDepartments.new_plug()
      |> FuelUsageDepartments.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_department,
      modal_title: "New Fuel Usage")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_type", _, socket) do
    changeset =
      FuelUsageTypes.new_plug()
      |> FuelUsageTypes.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_type,
      modal_title: "New Fuel Usage")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_yard", _, socket) do
    changeset =
      FuelUsageYards.new_plug()
      |> FuelUsageYards.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_yard,
      modal_title: "New Fuel Usage")
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    FuelUsages.delete_plug(cur.data)
    {:noreply, socket}
  end
end
