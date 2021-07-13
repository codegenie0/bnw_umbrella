defmodule BnwDashboardWeb.CattlePurchase.AnimalOrdering.AnimalOrderingLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Sexes
  }

  alias BnwDashboardWeb.CattlePurchase.AnimalOrdering.ChangeAnimalOrderingComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "sexes") ->
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
        page_title: "BNW Dashboard · Active Sexes",
        app: "Cattle Purchase",
        sex: "active",
        sexes: Sexes.get_active_sexes,
        modal: nil
      )

    if connected?(socket) do
      Sexes.subscribe()
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
  def handle_event("set-active-sexes", _params, socket) do
    {:noreply,
     assign(socket,
       sex: "active",
       page_title: "BNW Dashboard · Active Sex",
       sexes: Sexes.get_active_sexes()
     )}
  end

  @impl true
  def handle_event("set-inactive-sexes", _params, socket) do
    {:noreply,
     assign(socket,
       sex: "inactive",
       page_title: "BNW Dashboard · Inactive Sex",
       sexes: Sexes.get_inactive_sexes()
     )}
  end

  @impl true
  def handle_event("new", _params, socket) do
    changeset = Sexes.new_sex()
    socket = assign(socket, changeset: changeset, modal: :change_animal_ordering)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    changeset =
      Enum.find(socket.assigns.sexes, fn pt -> pt.id == id end)
      |> Sexes.change_sex()
    socket = assign(socket, changeset: changeset, modal: :change_animal_ordering)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    changeset =
      Enum.find(socket.assigns.sexes, fn pt -> pt.id == id end)
      |> Sexes.delete_sex()
    {:noreply, socket}
  end


  @impl true
  def handle_event("cancel", _params, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:sexes, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    sexes = socket.assigns.sexes
    data = fetch_by_type(socket.assigns.sex)
    {:noreply, assign(socket, sexes: data)}
  end

  @impl true
  def handle_info({[:sexes, :deleted], _}, socket) do
    sexes = socket.assigns.sexes
    data = fetch_by_type(socket.assigns.sex)
    {:noreply, assign(socket, sexes: data)}
  end

  defp fetch_by_type(sex_type) do
    if sex_type == "active",
      do: Sexes.get_active_sexes(),
      else: Sexes.get_inactive_sexes()
  end
end
