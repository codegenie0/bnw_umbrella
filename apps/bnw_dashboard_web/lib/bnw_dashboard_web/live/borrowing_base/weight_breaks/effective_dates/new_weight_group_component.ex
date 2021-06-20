defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.NewWeightGroupComponent do
  use BnwDashboardWeb, :live_component

  alias BorrowingBase.WeightGroups

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"weight_group" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> WeightGroups.change_weight_group(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"weight_group" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case WeightGroups.create_or_update_weight_group(changeset.data, params) do
      {:ok, _company} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
