defmodule BnwDashboardWeb.PlugsApp.CompanyVehicleMile.CompanyVehicleMileLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.CompanyVehicleMile.{
    ChangePlugComponent,
    ChangeYardComponent
  }
  alias PlugsApp.{
    CompanyVehicleMiles,
    CompanyVehicleMileYards,
    Authorize,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "vehicle_miles")
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
      CompanyVehicleMiles.list_plugs()
      |> Enum.map(&(CompanyVehicleMiles.change_plug(&1)))
    assign(socket, plugs: plugs)
  end

  defp fetch_extra(socket) do
    yards = CompanyVehicleMileYards.list_plugs()
    assign(socket, yards: yards)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> assign(page_title: "BNW Dashboard · Plugs Company Vehicle Miles",
                app: "Plugs",
                modal: nil)

    if connected?(socket) do
      Users.subscribe()
      CompanyVehicleMiles.subscribe()
      CompanyVehicleMileYards.subscribe()
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
  def handle_info({[:company_vehicle_mile, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile, :deleted], _}, socket) do
    socket = fetch_plugs(socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:company_vehicle_mile_yard, :created_or_updated], _}, socket) do
    socket = fetch_extra(socket)
      |> assign(modal: nil)
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
      modal_title: "Edit Company Vehicle  Miles",
      selected_yard: cur.data.yard)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_yard", _, socket) do
    changeset =
      CompanyVehicleMileYards.new_plug()
      |> CompanyVehicleMileYards.change_plug
    socket = assign(socket,
      changeset: changeset,
      modal: :change_yard,
      modal_title: "New Yard")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      CompanyVehicleMiles.new_plug()
      |> CompanyVehicleMiles.change_plug
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      modal_title: "New Company Vehicle Miles",
      selected_yard: 1)
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
    CompanyVehicleMiles.delete_plug(cur.data)
    {:noreply, socket}
  end
end
