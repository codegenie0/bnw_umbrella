defmodule BnwDashboardWeb.BorrowingBase.Companies.SexCodes.SexCodeLive do
  use BnwDashboardWeb, :live_view

  alias BorrowingBase.SexCodes
  #alias BnwDashboardWeb.BorrowingBase.Companies.CompaniesLive #unused alias

  @impl true
  def mount(_params, %{"changeset" => changeset, "company" => company}, socket) do
    socket = assign(socket, changeset: changeset, company: company)
    if connected?(socket), do: SexCodes.subscribe()
    {:ok, socket}
  end

  # handle info
  @impl true
  def handle_info({[:sex_code, :updated], sex_code}, socket) do
    %{changeset: changeset} = socket.assigns
    socket = cond do
      changeset.data.id == sex_code.id ->
        changeset = SexCodes.change_sex_code(changeset.data)
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
