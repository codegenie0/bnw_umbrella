defmodule BnwDashboardWeb.CihReportPlugs.Plugs.ChangePlugComponent do
  @moduledoc """
  ### Live view component for the add/update plug modal.
  This modal is auto populated with values from whatever plug was selected. On pressing the save button the handle_event save is called to commit the changes to the database and update the other live views subscribed to the page.
  """
  use BnwDashboardWeb, :live_component

  alias BnwDashboardWeb.CihReportPlugs.Plugs.PlugsLive
  alias CihReportPlugs.Plugs

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  def mount(socket) do
    {:ok, socket}
  end

  @doc """
  This function is called to commit the modified plug to the database and remove the modal from the screen.
  """
  def handle_event("save", %{"plug" => plug}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Plugs.validate(changeset.data, plug)
    if changeset.valid? do
      case Plugs.create_or_update_plug(changeset.data, plug) do
        {:ok, _plug} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, PlugsLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
