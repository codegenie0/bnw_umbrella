defmodule BnwDashboardWeb.CattlePurchase.States.ChangeStateComponent do
  @moduledoc """
  ### Live view component for the add/update state modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.States
  alias BnwDashboardWeb.CattlePurchase.State.StateLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"state" => state}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = States.validate(changeset.data, state)

    if changeset.valid? do
      case States.create_or_update_state(changeset.data, state) do
        {:ok, _state} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, StateLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"state" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> States.change_state(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
