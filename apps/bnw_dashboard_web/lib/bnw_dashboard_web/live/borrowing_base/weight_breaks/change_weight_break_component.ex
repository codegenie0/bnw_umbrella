defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.ChangeWeightBreakComponent do
  use BnwDashboardWeb, :live_component

  alias BorrowingBase.WeightBreaks

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"weight_break" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> WeightBreaks.change_weight_break(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"weight_break" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case WeightBreaks.create_or_update_weight_break(changeset.data, params) do
      {:ok, _company} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
