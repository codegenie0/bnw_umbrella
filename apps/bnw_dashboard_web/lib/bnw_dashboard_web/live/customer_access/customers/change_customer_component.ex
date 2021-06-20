defmodule BnwDashboardWeb.CustomerAccess.Customers.ChangeCustomerComponent do
  use BnwDashboardWeb, :live_component

  alias CustomerAccess.Customers
  alias BnwDashboardWeb.CustomerAccess.Customers.CustomersLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"customer" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    params = Map.delete(params, "report_types_ids")
    changeset =
      changeset.data
      |> Customers.change_customer(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"customer" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    case Customers.create_or_update_customer(changeset.data, params) do
      {:ok, _report} ->
        {:noreply, push_patch(socket, to: Routes.live_path(socket, CustomersLive))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
