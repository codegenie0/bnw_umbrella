defmodule BnwDashboardWeb.TentativeShip.Yards.LotStatusCodes.LotStatusCodeLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.LotStatusCodes

  @impl true
  def mount(_params, %{"lot_status_code" => lot_status_code, "yard_id" => yard_id, "id" => id}, socket) do
    changeset = LotStatusCodes.change_lot_status_code(lot_status_code)
    socket = assign(socket, changeset: changeset, yard_id: yard_id, view_id: id)
    if connected?(socket), do: LotStatusCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:lot_status_code, :updated], lot_status_code}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == lot_status_code.id ->
        changeset = LotStatusCodes.change_lot_status_code(lot_status_code)
        assign(socket, changeset: changeset)
      true -> socket
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("delete", _params, socket) do
    %{changeset: changeset} = socket.assigns
    LotStatusCodes.delete_lot_status_code(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"lot_status_code" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = LotStatusCodes.change_lot_status_code(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"lot_status_code" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case LotStatusCodes.create_or_update_lot_status_code(changeset.data, params) do
      {:ok, _lot_status_code} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # end handle event
end
