defmodule BnwDashboardWeb.TentativeShip.Yards.SexCodes.SexCodeLive do
  use BnwDashboardWeb, :live_view

  alias TentativeShip.SexCodes

  @impl true
  def mount(_params, %{"sex_code" => sex_code, "yard_id" => yard_id, "id" => id}, socket) do
    changeset = SexCodes.change_sex_code(sex_code)
    socket = assign(socket, changeset: changeset, yard_id: yard_id, view_id: id)
    if connected?(socket), do: SexCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:sex_code, :updated], sex_code}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == sex_code.id ->
        changeset = SexCodes.change_sex_code(sex_code)
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
    SexCodes.delete_sex_code(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"sex_code" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = SexCodes.change_sex_code(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"sex_code" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case SexCodes.create_or_update_sex_code(changeset.data, params) do
      {:ok, _sex_code} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end
  # end handle event
end
