defmodule BnwDashboardWeb.PlugsApp.OutsideBilling.ChangeLocationComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.OutsideBillingCustomers
  alias PlugsApp.OutsideBillingLocations

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = OutsideBillingLocations.new_plug()
      |> OutsideBillingLocations.change_plug()
    changeset = OutsideBillingLocations.validate(changeset.data, plug)
    if changeset.valid? do
      case OutsideBillingLocations.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = OutsideBillingLocations.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    OutsideBillingLocations.get_plug_struct(id)
    |> OutsideBillingLocations.delete_plug()
    {:noreply, socket}
  end
end
