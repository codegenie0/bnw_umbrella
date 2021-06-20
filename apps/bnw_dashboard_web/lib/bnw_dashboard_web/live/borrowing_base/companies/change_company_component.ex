defmodule BnwDashboardWeb.BorrowingBase.Companies.ChangeCompanyComponent do
  use BnwDashboardWeb, :live_component

  alias BorrowingBase.Companies

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"company" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Companies.change_company(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"company" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Companies.create_or_update_company(changeset.data, params) do
      {:ok, _company} ->
        send self(), {:save, nil}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
