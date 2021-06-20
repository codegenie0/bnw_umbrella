defmodule BnwDashboardWeb.PlugsApp.PackerTysonPricing.PackerTysonPricingLive do

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.PlugsApp.PackerTysonPricing.ChangePlugComponent
  alias PlugsApp.{
    PackerTysonPricings,
    Authorize,
    Users
  }

  defp get_role(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    if current_user do
      Authorize.authorize(current_user, "tyson_packer")
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
      PackerTysonPricings.list_plugs()
      |> Enum.map(&(PackerTysonPricings.change_plug(&1)))
    assign(socket, plugs: plugs)
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> fetch_plugs()
      |> fetch_permissions()
      |> assign(page_title: "BNW Dashboard · Plugs Packer Tyson Pricing",
                app: "Plugs",
                section: "1",
                modal: nil)

    if connected?(socket) do
      PackerTysonPricings.subscribe()
      Users.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info({[:packer_tyson_pricing, :created_or_updated], _}, socket) do
    socket = fetch_plugs(socket)
      |> assign(modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:packer_tyson_pricing, :deleted], _}, socket) do
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
    socket = assign(socket, changeset: cur, modal: :change_plug, modal_title: "Edit PackerTysonPricing")
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      PackerTysonPricings.new_plug()
      |> PackerTysonPricings.change_plug
    socket = assign(socket, changeset: changeset, modal: :change_plug, modal_title: "New PackerTysonPricing")
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
    PackerTysonPricings.delete_plug(cur.data)
    {:noreply, socket}
  end
end
