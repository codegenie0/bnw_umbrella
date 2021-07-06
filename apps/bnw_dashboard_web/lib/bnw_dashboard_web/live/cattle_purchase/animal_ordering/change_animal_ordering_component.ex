defmodule BnwDashboardWeb.CattlePurchase.AnimalOrdering.ChangeAnimalOrderingComponent do
  @moduledoc """
    Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias BnwDashboardWeb.CattlePurchase.AnimalOrdering.AnimalOrderingLive
  alias CattlePurchase.{
    Authorize,
    Sexes
  }
  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"sex" => sex}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Sexes.validate(changeset.data, sex)
    if changeset.valid? do
      case Sexes.create_or_update_sex(changeset.data, sex) do
        {:ok, _sex} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, AnimalOrderingLive))}
        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"sex" => params}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset =
      changeset.data
      |> Sexes.change_sex(params)
      |> Map.put(:action, :update)
    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
