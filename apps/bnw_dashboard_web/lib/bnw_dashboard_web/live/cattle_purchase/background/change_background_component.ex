defmodule BnwDashboardWeb.CattlePurchase.Backgrounds.ChangeBackgroundComponent do
  @moduledoc """
  ### Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.Backgrounds
  alias BnwDashboardWeb.CattlePurchase.Background.BackgroundLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"background" => background}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = Backgrounds.validate(changeset.data, background)

    if changeset.valid? do
      case Backgrounds.create_or_update_background(changeset.data, background) do
        {:ok, _background} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, BackgroundLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"background" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> Backgrounds.change_background(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
