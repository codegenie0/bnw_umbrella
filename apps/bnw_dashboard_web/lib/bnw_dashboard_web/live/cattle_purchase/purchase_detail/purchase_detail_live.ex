defmodule BnwDashboardWeb.CattlePurchase.PurchaseDetail.PurchaseDetailLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Purchases,
    Purchase,
    Shipments,
    PurchaseDetails,
    Sexes,
    Repo
  }

  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseDetailComponent
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "purchases") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(params, session, socket) do
    sort_columns = [
      "Purchase Date",
      "Purchase Order",
      "Delivered",
      "Buyer",
      "Destination",
      "Ship Date",
      "Firm"
    ]

    {id, ""} = Integer.parse(params["id"])

    purchase =
      Repo.get(Purchase, id)
      |> Repo.preload([:purchase_buyer])

    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Purchase Details",
        app: "Cattle Purchase",
        purchase: purchase,
        purchase_details: PurchaseDetails.get_purchase_detail_from_purchase(id),
        sort_columns: sort_columns,
        modal: nil,
        add_feedback: false
      )

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info({:purchase_detail_updated, purchase_id: purchase_id}, socket) do
    {:noreply,
     assign(socket,
       modal: nil,
       purchase_details: PurchaseDetails.get_purchase_detail_from_purchase(purchase_id)
     )}
  end

  def handle_info({:purchase_detail_created, button: button, purchase_id: purchase_id}, socket) do
    {:noreply,
     assign(socket,
       modal: nil,
       purchase_details: PurchaseDetails.get_purchase_detail_from_purchase(purchase_id)
     )}
  end

  @impl true
  def handle_event("new", params, socket) do
    {purchase_id, ""} = Integer.parse(params["id"])

    initial_purchase_details = %{
      sex_id: "",
      head_count: 0,
      average_weight: 0,
      price: 0,
      projected_break_even: 0,
      projected_out_date: "",
      purchase_basis: "",
      valid: true
    }

    socket =
      assign(socket,
        sexes: Sexes.get_active_sexes(),
        purchase_detail_edit_phase: false,
        purchase_detail_changeset: PurchaseDetails.new_purchase_detail(),
        purchase_details_in_form: [initial_purchase_details],
        purchase_details_from_db: [initial_purchase_details],
        modal: :change_purchase_detail
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    purchase_detail = Enum.find(socket.assigns.purchase_details, fn pd -> pd.id == id end)

    socket =
      assign(socket,
        modal: :change_purchase_detail,
        sexes: Sexes.get_active_sexes(),
        purchase_detail_edit_phase: true,
        purchase_detail_changeset: PurchaseDetails.new_purchase_detail(),
        purchase_details_in_form: [Map.put(purchase_detail, :valid, true)],
        purchase_details_from_db: purchase_detail
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.purchase_details, fn pd -> pd.id == id end)
    |> PurchaseDetails.delete_purchase_detail()

    {:noreply,
     assign(socket,
       modal: nil,
       purchase_details:
         PurchaseDetails.get_purchase_detail_from_purchase(socket.assigns.purchase.id)
     )}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end
end
