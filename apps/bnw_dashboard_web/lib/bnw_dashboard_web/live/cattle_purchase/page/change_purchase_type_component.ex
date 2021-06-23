defmodule BnwDashboardWeb.CattlePurchase.Page.ChangePurchaseTypeComponent do
  @moduledoc """
  ### Live view component for the add/update plug modal.
  This modal is auto populated with values from whatever plug was selected. On pressing the save button the handle_event save is called to commit the changes to the database and update the other live views subscribed to the page.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PurchaseTypes
  alias BnwDashboardWeb.CattlePurchase.Page.PurchaseTypeLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"purchase_type" => purchase_type}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = PurchaseTypes.validate(changeset.data, purchase_type)

    if changeset.valid? do
      case PurchaseTypes.create_or_update_purchase_type(changeset.data, purchase_type) do
        {:ok, _plug} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseTypeLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"purchase_type" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> PurchaseTypes.change_purchase_type(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
