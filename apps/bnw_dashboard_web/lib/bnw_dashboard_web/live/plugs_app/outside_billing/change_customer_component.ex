defmodule BnwDashboardWeb.PlugsApp.OutsideBilling.ChangeCustomerComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.OutsideBillingCustomers

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = OutsideBillingCustomers.new_plug()
      |> OutsideBillingCustomers.change_plug()
    changeset = OutsideBillingCustomers.validate(changeset.data, plug)
    if changeset.valid? do
      case OutsideBillingCustomers.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = OutsideBillingCustomers.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    OutsideBillingCustomers.get_plug_struct(id)
    |> OutsideBillingCustomers.delete_plug()
    {:noreply, socket}
  end
end
