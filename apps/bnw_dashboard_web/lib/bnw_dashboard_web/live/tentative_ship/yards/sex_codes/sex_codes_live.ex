defmodule BnwDashboardWeb.TentativeShip.Yards.SexCodes.SexCodesLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.SexCodes
  alias BnwDashboardWeb.TentativeShip.Yards.SexCodes.SexCodeLive

  defp fetch_sex_codes(socket) do
    %{yard_id: yard_id} = socket.assigns
    sex_codes =
      (SexCodes.list_sex_codes(yard_id) ++ [SexCodes.new_sex_code()])
    assign(socket, sex_codes: sex_codes)
  end

  defp set_sex_codes(sex_code, socket) do
    %{yard_id: yard_id} = socket.assigns
    cond do
      yard_id == sex_code.yard_id -> fetch_sex_codes(socket)
      true -> socket
    end
  end

  @impl true
  def mount(_params, session, socket) do
    %{"parent_pid" => parent_pid, "yard_id" => yard_id} = session
    socket =
      socket
      |> assign(yard_id: yard_id, parent_pid: parent_pid)
      |> fetch_sex_codes()
    if connected?(socket), do: SexCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:sex_code, :created], sex_code}, socket) do
    socket = set_sex_codes(sex_code, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_info({[:sex_code, :deleted], sex_code}, socket) do
    socket = set_sex_codes(sex_code, socket)
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
