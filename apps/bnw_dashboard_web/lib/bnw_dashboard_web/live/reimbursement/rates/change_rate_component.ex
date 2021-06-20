defmodule BnwDashboardWeb.Reimbursement.Rates.ChangeRateComponent do
  @moduledoc """
  ### Live view component for the add/update Rate modal.
  This modal is auto populated with values from whichever plug was selected. On pressing the save button the handle_event save is called to commit the changes to the database and update the other live views subscribed to the page.
  """

  use BnwDashboardWeb, :live_component

  alias BnwDashboardWeb.Reimbursement.Rates.RatesLive
  alias Reimbursement.Rates

  @doc """
  This function is the entry point for the live view. This is called when live_component(..., this, ...) is called
  """
  def mount(socket) do
    {:ok, socket}
  end

  @doc """
  This function is called to commit the modified entry to the database and remove the modal from the screen.
  """
  def handle_event("save", %{"rate" => rate}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Rates.validate(changeset.data, rate)
    if changeset.valid? do
      case Rates.create_or_update_rate(changeset.data, rate) do
        {:ok, _rate} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, RatesLive))}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"rate" => rate}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Rates.validate(changeset.data, rate)
    {:noreply, assign(socket, changeset: changeset)}
  end
end
