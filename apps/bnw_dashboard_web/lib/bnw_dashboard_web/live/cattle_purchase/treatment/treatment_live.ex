defmodule BnwDashboardWeb.CattlePurchase.Treatment.TreatmentLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Treatments
  }

  alias BnwDashboardWeb.CattlePurchase.Treatments.ChangeTreatmentComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "treatments") ->
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
        page_title: "Active Treatment",
        app: "Cattle Purchase",
        treatment: "active",
        treatments: Treatments.get_active_treatments(),
        modal: nil
      )

    if connected?(socket) do
      Treatments.subscribe()
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
    changeset = Treatments.new_treatment()
    socket = assign(socket, changeset: changeset, modal: :change_treatment)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.treatments, fn pt -> pt.id == id end)
      |> Treatments.change_treatment()

    socket = assign(socket, changeset: changeset, modal: :change_treatment)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.treatments, fn pt -> pt.id == id end)
    |> Treatments.delete_treatment()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-treatment", _params, socket) do
    {:noreply,
     assign(socket,
       treatment: "active",
       page_title: "Active Treatment",
       treatments: Treatments.get_active_treatments()
     )}
  end

  @impl true
  def handle_event("set-inactive-treatment", _params, socket) do
    {:noreply,
     assign(socket,
       treatment: "inactive",
       page_title: "Inactive Treatment",
       treatments: Treatments.get_inactive_treatments()
     )}
  end

  @impl true
  def handle_info({[:treatments, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    treatment = socket.assigns.treatment
    data = fetch_by_type(treatment)
    {:noreply, assign(socket, treatments: data)}
  end

  @impl true
  def handle_info({[:treatments, :deleted], _}, socket) do
    treatment = socket.assigns.treatment
    data = fetch_by_type(treatment)
    {:noreply, assign(socket, treatments: data)}
  end

  defp fetch_by_type(treatment) do
    if treatment == "active",
      do: Treatments.get_active_treatments(),
      else: Treatments.get_inactive_treatments()
  end
end
