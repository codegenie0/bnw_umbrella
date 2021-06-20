defmodule BnwDashboardWeb.Reimbursement.Update.ChangeEntryComponent do
  @moduledoc """
  ### Live view component for the add/update Entry modal.
  This modal is auto populated with values from whichever plug was selected. On pressing the save button the handle_event save is called to commit the changes to the database and update the other live views subscribed to the page.
  """

  use BnwDashboardWeb, :live_component

  alias BnwDashboardWeb.Reimbursement.Update.UpdateLive
  alias Reimbursement.Entries

  defp set_up_radio(socket) do
    radios = [
      %{key: "Mileage",       value: 1, full: "Enter the number of miles Driven on this trip."},
      %{key: "Odometer",      value: 2, full: "Enter the starting and ending Odometer readings on this trip."},
      %{key: "Miscellaneous", value: 3, full: "Enter a miscellaneous amount ie. A road snack"}
    ]

    assign(socket, radios: radios)
  end

  @doc """
  This function is the entry point for the live view. This is called when live_component(..., this, ...) is called
  """
  def mount(socket) do
    socket = set_up_radio(socket)
    {:ok, socket}
  end

  @doc """
  This function is called to commit the modified entry to the database and remove the modal from the screen.
  """
  def handle_event("save", %{"entry" => entry}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Entries.validate(changeset.data, entry)
    if changeset.valid? do
      case Entries.create_or_update_entry(changeset.data, entry) do
        {:ok, _entry} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, UpdateLive))}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("option", %{"option" => option}, socket) do
    socket = assign(socket, radio: String.to_integer(option))
    {:noreply, socket}
  end

  def handle_event("validate", %{"entry" => entry}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Entries.validate(changeset.data, entry)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
