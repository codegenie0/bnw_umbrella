defmodule BnwDashboardWeb.BorrowingBase.Companies.Yards.YardLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Yards

  @impl true
  def mount(_params, %{"changeset" => changeset, "company" => company}, socket) do
    socket = assign(socket, changeset: changeset, company: company)
    if connected?(socket), do: Yards.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:yard, :updated], yard}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == yard.id ->
        changeset = Yards.change_yard(changeset.data)
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
    Yards.delete_yard(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"yard" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Yards.change_yard(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"yard" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Yards.create_or_update_yard(changeset.data, params) do
      {:ok, _yard} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # end handle event
end
