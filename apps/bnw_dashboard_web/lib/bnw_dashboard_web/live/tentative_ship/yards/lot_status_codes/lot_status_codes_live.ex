defmodule BnwDashboardWeb.TentativeShip.Yards.LotStatusCodes.LotStatusCodesLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.LotStatusCodes
  alias BnwDashboardWeb.TentativeShip.Yards.LotStatusCodes.LotStatusCodeLive

  defp fetch_lot_status_codes(socket) do
    %{yard_id: yard_id} = socket.assigns
    lot_status_codes =
      (LotStatusCodes.list_lot_status_codes(yard_id) ++ [LotStatusCodes.new_lot_status_code()])
    assign(socket, lot_status_codes: lot_status_codes)
  end

  defp set_lot_status_codes(lot_status_code, socket) do
    %{yard_id: yard_id} = socket.assigns
    cond do
      yard_id == lot_status_code.yard_id -> fetch_lot_status_codes(socket)
      true -> socket
    end
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    socket =
      socket
      |> assign(yard_id: yard_id, parent_pid: parent_pid)
      |> fetch_lot_status_codes()
    if connected?(socket), do: LotStatusCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:lot_status_code, :created], lot_status_code}, socket) do
    socket = set_lot_status_codes(lot_status_code, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:lot_status_code, :deleted], lot_status_code}, socket) do
    socket = set_lot_status_codes(lot_status_code, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle info

  # handle event
  @impl true
  def handle_event("cancel", _, socket) do
    %{parent_pid: parent_pid} = socket.assigns
    send(parent_pid, {:save, nil})
    {:noreply, socket}
  end
  # end handle event
end
