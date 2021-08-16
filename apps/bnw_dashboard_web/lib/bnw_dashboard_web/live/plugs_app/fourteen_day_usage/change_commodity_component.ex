defmodule BnwDashboardWeb.PlugsApp.FourteenDayUsage.ChangeCommodityComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.FourteenDayUsageCommodities

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    %{yard: yard} = socket.assigns
    plug = Map.put(plug, "yard", yard)
    changeset = FourteenDayUsageCommodities.new_plug()
      |> FourteenDayUsageCommodities.change_plug()
    changeset = FourteenDayUsageCommodities.validate(changeset.data, plug)
    if changeset.valid? do
      case FourteenDayUsageCommodities.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = FourteenDayUsageCommodities.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    FourteenDayUsageCommodities.get_plug_struct(id)
    |> FourteenDayUsageCommodities.delete_plug()
    {:noreply, socket}
  end
end
