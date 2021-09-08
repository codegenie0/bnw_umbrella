defmodule BnwDashboardWeb.CattlePurchase.Programs.ChangeProgramComponent do
  @moduledoc """
  ### Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Programs
  alias BnwDashboardWeb.CattlePurchase.Program.ProgramLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"program" => program}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Programs.validate(changeset.data, program)

    if changeset.valid? do
      case Programs.create_or_update_program(changeset.data, program) do
        {:ok, _program} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, ProgramLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"program" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Programs.change_program(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
