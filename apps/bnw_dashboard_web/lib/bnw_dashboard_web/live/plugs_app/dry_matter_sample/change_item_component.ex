defmodule BnwDashboardWeb.PlugsApp.DryMatterSample.ChangeItemComponent do
  use BnwDashboardWeb, :live_component

  alias PlugsApp.DryMatterSampleItems

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("new", %{"new" => plug}, socket) do
    %{yard: yard} = socket.assigns
    plug = Map.put(plug, "yard", yard)
    changeset = DryMatterSampleItems.new_plug()
      |> DryMatterSampleItems.change_plug()
    changeset = DryMatterSampleItems.validate(changeset.data, plug)
    if changeset.valid? do
      case DryMatterSampleItems.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          changeset = DryMatterSampleItems.new_plug()
          {:noreply, assign(socket, changeset: changeset)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    DryMatterSampleItems.get_plug_struct(id)
    |> DryMatterSampleItems.delete_plug()
    {:noreply, socket}
  end
end
