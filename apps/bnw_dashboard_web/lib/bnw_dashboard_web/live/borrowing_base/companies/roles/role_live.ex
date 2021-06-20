defmodule BnwDashboardWeb.BorrowingBase.Companies.Roles.RoleLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.Roles

  @impl true
  def mount(_params, %{"changeset" => changeset, "company" => company}, socket) do
    yards =
      cond do
        Ecto.get_meta(changeset.data, :state) == :loaded ->
          changeset.data
          |> Map.put(:company_id, company)
          |> Roles.list_yards()
        true -> nil
      end
    socket = assign(socket, changeset: changeset, company: company, yards: yards)
    if connected?(socket), do: Roles.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:role, :updated], role}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == role.id ->
        changeset = Roles.change_role(changeset.data)
        yards = Roles.list_yards(changeset.data)
        assign(socket, changeset: changeset, yards: yards)
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
    Roles.delete_role(changeset.data)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"role" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Roles.change_role(changeset.data, params)
    |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"role" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Roles.create_or_update_role(changeset.data, params) do
      {:ok, _role} ->
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("yard", %{"yard-id" => yard_id}, socket) do
    %{changeset: changeset} = socket.assigns
    Roles.add_yard(changeset.data, yard_id)
    {:noreply, socket}
  end
  # end handle event
end
