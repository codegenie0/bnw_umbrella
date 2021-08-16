defmodule BnwDashboardWeb.TentativeShip.Yards.ChangeYardComponent do
  use BnwDashboardWeb, :live_component

  alias TentativeShip.Yards

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"yard" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Yards.change_yard(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"yard" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Yards.create_or_update_yard(changeset.data, params) do
      {:ok, _yard} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
