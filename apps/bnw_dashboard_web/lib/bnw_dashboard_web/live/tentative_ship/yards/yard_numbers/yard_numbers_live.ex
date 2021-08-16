defmodule BnwDashboardWeb.TentativeShip.Yards.YardNumbers.YardNumbersLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.YardNumbers
  alias BnwDashboardWeb.TentativeShip.Yards.YardNumbers.YardNumberLive

  defp fetch_yard_numbers(socket) do
    %{yard_id: yard_id} = socket.assigns
    yard_numbers =
      (YardNumbers.list_yard_numbers(yard_id) ++ [YardNumbers.new_yard_number()])
    assign(socket, yard_numbers: yard_numbers)
  end

  defp set_yard_numbers(yard_number, socket) do
    %{yard_id: yard_id} = socket.assigns
    cond do
      yard_id == yard_number.yard_id -> fetch_yard_numbers(socket)
      true -> socket
    end
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    socket =
      socket
      |> assign(yard_id: yard_id, parent_pid: parent_pid)
      |> fetch_yard_numbers()
    if connected?(socket), do: YardNumbers.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:yard_number, :created], yard_number}, socket) do
    socket = set_yard_numbers(yard_number, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:yard_number, :deleted], yard_number}, socket) do
    socket = set_yard_numbers(yard_number, socket)
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
