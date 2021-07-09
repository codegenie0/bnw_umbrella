defmodule BnwDashboardWeb.CattlePurchase.WeightCategories.ChangeWeightCategoryComponent do
  @moduledoc """
  ### Live view component for the add/update purchase flags modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.WeightCategories
  alias BnwDashboardWeb.CattlePurchase.WeightCategory.WeightCategoryLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"weight_category" => weight_category}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = WeightCategories.validate(changeset.data, weight_category)

    if changeset.valid? do
      case WeightCategories.create_or_update_weight_category(changeset.data, weight_category) do
        {:ok, _weight_category} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, WeightCategoryLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"weight_category" => params}, socket) do
    IO.puts("-------------")
    IO.inspect(params)
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> WeightCategories.change_weight_category(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
