defmodule BnwDashboardWeb.CattlePurchase.Purchase.ChangePurchaseComponent do
  @moduledoc """
  ### Live view component for the add/update purchase modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Purchases
  alias BnwDashboardWeb.CattlePurchase.Purchase.PurchaseLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"purchase" => purchase}, socket) do
    purchase =
      Map.put(purchase, "purchase_flag_ids", get_purchase_flags(socket.assigns.purchase_flags))

    %{changeset: changeset} = socket.assigns
    changeset = Purchases.validate(changeset.data, purchase)

    if changeset.valid? do
      case Purchases.create_or_update_purchase(changeset.data, purchase) do
        {:ok, _purchase} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"purchase" => params}, socket) do
    params =
      Map.put(params, "purchase_flag_ids", get_purchase_flags(socket.assigns.purchase_flags))

    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Purchases.change_purchase(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "handle_toggle_purchase_flag",
        %{"id" => _} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])

    purchase_flags =
      socket.assigns.purchase_flags
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, !item.checked)
        else
          item
        end
      end)

    {:noreply, assign(socket, purchase_flags: purchase_flags)}
  end

  def get_purchase_flags(purchase_flags) do
    Enum.reduce(purchase_flags, [], fn purchase_flag, list ->
      if(purchase_flag.checked) do
        list ++ [purchase_flag.id]
      else
        list
      end
    end)
  end
end
