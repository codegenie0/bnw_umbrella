defmodule BnwDashboardWeb.CattlePurchase.Treatments.ChangeTreatmentComponent do
  @moduledoc """
  ### Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Treatments
  alias BnwDashboardWeb.CattlePurchase.Treatment.TreatmentLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"treatment" => treatment}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Treatments.validate(changeset.data, treatment)

    if changeset.valid? do
      case Treatments.create_or_update_treatment(changeset.data, treatment) do
        {:ok, _treatment} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, TreatmentLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"treatment" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Treatments.change_treatment(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
