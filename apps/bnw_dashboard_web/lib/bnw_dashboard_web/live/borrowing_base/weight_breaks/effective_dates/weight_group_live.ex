defmodule BnwDashboardWeb.BorrowingBase.WeightBreaks.EffectiveDates.WeightGroupLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.{
    EffectiveDates,
    WeightGroups
  }

  @impl true
  def mount(_params, %{"weight_group" => weight_group, "even" => even, "effective_date" => effective_date, "genders" => genders}, socket) do
    changeset = WeightGroups.change_weight_group(weight_group)
    socket = assign(socket, changeset: changeset, even: even, effective_date: effective_date, genders: genders)
    if connected?(socket) do
      EffectiveDates.subscribe()
      WeightGroups.subscribe()
    end
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:weight_group, :updated], weight_group}, socket) do
    %{changeset: changeset} = socket.assigns

    socket = cond do
      weight_group.id == changeset.data.id ->
        changeset = WeightGroups.change_weight_group(weight_group)
        assign(socket, changeset: changeset)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:effective_date, :updated], result}, socket) do
    %{effective_date: effective_date} = socket.assigns
    socket = cond do
      effective_date.id == result.id -> assign(socket, effective_date: result)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # handle info end

  # handle event
  @impl true
  def handle_event("delete", _params, socket) do
    %{changeset: changeset} = socket.assigns
    WeightGroups.delete_weight_group(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"weight_group" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case WeightGroups.create_or_update_weight_group(changeset.data, params) do
      {:ok, _weight_group} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # handle event end
end
