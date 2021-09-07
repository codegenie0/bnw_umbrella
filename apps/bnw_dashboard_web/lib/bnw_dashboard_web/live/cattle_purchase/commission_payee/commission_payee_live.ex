defmodule BnwDashboardWeb.CattlePurchase.CommissionPayee.CommissionPayeeLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    CommissionPayees
  }

  alias BnwDashboardWeb.CattlePurchase.CommissionPayees.ChangeCommissionPayeeComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "commission_payees") ->
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
        page_title: "Active Commission Payee",
        app: "Cattle Purchase",
        commission_payee: "active",
        commission_payees: CommissionPayees.get_active_commission_payees(),
        modal: nil
      )

    if connected?(socket) do
      CommissionPayees.subscribe()
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
    changeset = CommissionPayees.new_commission_payee()
    socket = assign(socket, changeset: changeset, modal: :change_commission_payee)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.commission_payees, fn pt -> pt.id == id end)
      |> CommissionPayees.change_commission_payee()

    socket = assign(socket, changeset: changeset, modal: :change_commission_payee)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.commission_payees, fn pt -> pt.id == id end)
    |> CommissionPayees.delete_commission_payee()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-commission_payee", _params, socket) do
    {:noreply,
     assign(socket,
       commission_payee: "active",
       page_title: "Active Commission Payee",
       commission_payees: CommissionPayees.get_active_commission_payees()
     )}
  end

  @impl true
  def handle_event("set-inactive-commission_payee", _params, socket) do
    {:noreply,
     assign(socket,
       commission_payee: "inactive",
       page_title: "Inactive Commission Payee",
       commission_payees: CommissionPayees.get_inactive_commission_payees()
     )}
  end

  @impl true
  def handle_info({[:commission_payees, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    commission_payee = socket.assigns.commission_payee
    data = fetch_by_type(commission_payee)
    {:noreply, assign(socket, commission_payees: data)}
  end

  @impl true
  def handle_info({[:commission_payees, :deleted], _}, socket) do
    commission_payee = socket.assigns.commission_payee
    data = fetch_by_type(commission_payee)
    {:noreply, assign(socket, commission_payees: data)}
  end

  defp fetch_by_type(commission_payee) do
    if commission_payee == "active",
      do: CommissionPayees.get_active_commission_payees(),
      else: CommissionPayees.get_inactive_commission_payees()
  end
end
