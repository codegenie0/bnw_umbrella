defmodule BnwDashboardWeb.CattlePurchase.PurchaseBuyers.ChangePurchaseBuyerComponent do
  @moduledoc """
  ### Live view component for the add/update purchase buyer modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PurchaseBuyers
  alias BnwDashboardWeb.CattlePurchase.PurchaseBuyer.PurchaseBuyerLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"purchase_buyer" => purchase_buyer}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = PurchaseBuyers.validate(changeset.data, purchase_buyer)
    if changeset.valid? do
      case PurchaseBuyers.create_or_update_purchase_buyer(changeset.data, purchase_buyer) do
        {:ok, _purchase_buyer} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseBuyerLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"purchase_buyer" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> PurchaseBuyers.change_purchase_buyer(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
