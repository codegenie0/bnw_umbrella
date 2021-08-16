defmodule BnwDashboardWeb.PlugsApp.OutsideBilling.ChangeServiceTypeComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.OutsideBillingServiceTypes

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    changeset = OutsideBillingServiceTypes.new_plug()
    |> OutsideBillingServiceTypes.change_plug()
    changeset = OutsideBillingServiceTypes.validate(changeset.data, plug)
    if changeset.valid? do
      case OutsideBillingServiceTypes.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = OutsideBillingServiceTypes.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    OutsideBillingServiceTypes.get_plug_struct(id)
    |> OutsideBillingServiceTypes.delete_plug()
    {:noreply, socket}
  end
end
