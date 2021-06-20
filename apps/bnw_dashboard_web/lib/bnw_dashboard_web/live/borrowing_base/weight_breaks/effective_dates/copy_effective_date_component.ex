defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.CopyEffectiveDateComponent do
  use BnwDashboardWeb, :live_component

  alias BorrowingBase.EffectiveDates

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"effective_date" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> EffectiveDates.change_effective_date(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"effective_date" => params}, socket) do
    %{changeset: changeset, effective_date: effective_date} = socket.assigns
    case EffectiveDates.copy_effective_date(effective_date, changeset.data, params) do
      {:ok, _company} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
    {:noreply, socket}
  end
end
