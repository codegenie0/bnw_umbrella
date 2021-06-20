defmodule BnwDashboardWeb.PlugsApp.ProfitCenterKey.ProfitCenterKeyLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.ProfitCenterKey.{
    ChangePlugComponent,
    ChangeCompanyComponent,
  }
  alias PlugsApp.{
    ProfitCenterKeys,
    ProfitCenterKeyCompanies,
    Authorize,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "profit_center")
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
      ProfitCenterKeys.list_plugs()
      |> Enum.map(&(ProfitCenterKeys.change_plug(&1)))
    assign(socket, plugs: plugs)
  end

  defp fetch_extra(socket) do
    companies = ProfitCenterKeyCompanies.list_plugs()
    assign(socket,
      companies: companies
    )
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> fetch_plugs()
      |> fetch_extra()
      |> fetch_permissions()
      |> assign(page_title: "BNW Dashboard · Plugs Profit Center Key",
                app: "Plugs",
                modal: nil)

    if connected?(socket) do
      ProfitCenterKeys.subscribe()
      ProfitCenterKeyCompanies.subscribe()
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
  def handle_info({[:profit_center_key_company, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
    |> fetch_extra()
    |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:profit_center_key, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:profit_center_key, :deleted], _}, socket) do
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
      selected_company: cur.data.company,
      modal_title: "Edit Profit Center Key")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      ProfitCenterKeys.new_plug()
      |> ProfitCenterKeys.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_plug,
      selected_company: 1,
      modal_title: "New ProfitCenterKey")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_company", _, socket) do
    changeset =
      ProfitCenterKeyCompanies.new_plug()
      |> ProfitCenterKeyCompanies.change_plug()
    socket = assign(socket,
      changeset: changeset,
      modal: :change_company,
      modal_title: "New Profit Center Key")
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
    ProfitCenterKeys.delete_plug(cur.data)
    {:noreply, socket}
  end
end
