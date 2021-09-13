defmodule BnwDashboardWeb.CattlePurchase.Background.BackgroundLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Backgrounds
  }

  alias BnwDashboardWeb.CattlePurchase.Backgrounds.ChangeBackgroundComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "backgrounds") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Active Background",
        app: "Cattle Purchase",
        background: "active",
        backgrounds: Backgrounds.get_active_backgrounds(),
        modal: nil
      )

    if connected?(socket) do
      Backgrounds.subscribe()
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
  def handle_event("new", _, socket) do
    changeset = Backgrounds.new_background()
    socket = assign(socket, changeset: changeset, modal: :change_background)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.backgrounds, fn pt -> pt.id == id end)
      |> Backgrounds.change_background()

    socket = assign(socket, changeset: changeset, modal: :change_background)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.backgrounds, fn pt -> pt.id == id end)
    |> Backgrounds.delete_background()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-background", _params, socket) do
    {:noreply,
     assign(socket,
       background: "active",
       page_title: "Active Background",
       backgrounds: Backgrounds.get_active_backgrounds()
     )}
  end

  @impl true
  def handle_event("set-inactive-background", _params, socket) do
    {:noreply,
     assign(socket,
       background: "inactive",
       page_title: "Inactive Background",
       backgrounds: Backgrounds.get_inactive_backgrounds()
     )}
  end

  @impl true
  def handle_info({[:backgrounds, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    background = socket.assigns.background
    data = fetch_by_type(background)
    {:noreply, assign(socket, backgrounds: data)}
  end

  @impl true
  def handle_info({[:backgrounds, :deleted], _}, socket) do
    background = socket.assigns.background
    data = fetch_by_type(background)
    {:noreply, assign(socket, backgrounds: data)}
  end

  defp fetch_by_type(background) do
    if background == "active",
      do: Backgrounds.get_active_backgrounds(),
      else: Backgrounds.get_inactive_backgrounds()
  end
end
