defmodule BnwDashboardWeb.CattlePurchase.ContractTerm.ContractTermLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    ContractTerms
  }

  alias BnwDashboardWeb.CattlePurchase.ContractTerms.ChangeContractTermComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "contract_terms") ->
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
        page_title: "Active Contract Term",
        app: "Cattle Purchase",
        contract_term: "active",
        contract_terms: ContractTerms.get_active_contract_terms(),
        modal: nil
      )

    if connected?(socket) do
      ContractTerms.subscribe()
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
    changeset = ContractTerms.new_contract_term()
    socket = assign(socket, changeset: changeset, modal: :change_contract_term)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.contract_terms, fn pt -> pt.id == id end)
      |> ContractTerms.change_contract_term()

    socket = assign(socket, changeset: changeset, modal: :change_contract_term)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.contract_terms, fn pt -> pt.id == id end)
    |> ContractTerms.delete_contract_term()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-contract_term", _params, socket) do
    {:noreply,
     assign(socket,
       contract_term: "active",
       page_title: "Active Contract Term",
       contract_terms: ContractTerms.get_active_contract_terms()
     )}
  end

  @impl true
  def handle_event("set-inactive-contract_term", _params, socket) do
    {:noreply,
     assign(socket,
       contract_term: "inactive",
       page_title: "Inactive Contract Term",
       contract_terms: ContractTerms.get_inactive_contract_terms()
     )}
  end

  @impl true
  def handle_info({[:contract_terms, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    contract_term = socket.assigns.contract_term
    data = fetch_by_type(contract_term)
    {:noreply, assign(socket, contract_terms: data)}
  end

  @impl true
  def handle_info({[:contract_terms, :deleted], _}, socket) do
    contract_term = socket.assigns.contract_term
    data = fetch_by_type(contract_term)
    {:noreply, assign(socket, contract_terms: data)}
  end

  defp fetch_by_type(contract_term) do
    if contract_term == "active",
      do: ContractTerms.get_active_contract_terms(),
      else: ContractTerms.get_inactive_contract_terms()
  end
end
