defmodule BnwDashboardWeb.CattlePurchase.Sellers.ChangeSellerComponent do
  @moduledoc """
  ### Live view component for the add/update seller modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Sellers
  alias BnwDashboardWeb.CattlePurchase.Seller.SellerLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"seller" => seller}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Sellers.validate(changeset.data, seller)
    if changeset.valid? do
      case Sellers.create_or_update_seller(changeset.data, seller) do
        {:ok, _seller} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, SellerLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"seller" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Sellers.change_seller(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
