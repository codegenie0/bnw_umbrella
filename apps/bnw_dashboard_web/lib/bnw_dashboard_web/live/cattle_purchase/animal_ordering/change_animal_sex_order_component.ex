defmodule BnwDashboardWeb.CattlePurchase.AnimalSexOrder.ChangeAnimalSexOrderComponent do
  @moduledoc """
  ### Live view component for the add/update purchase types modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.AnimalSexOrders
  alias BnwDashboardWeb.CattlePurchase.AnimalSexOrder.AnimalSexOrderLive

  def mount(socket) do
    sex_list =
      AnimalSexOrders.get_all_sexes()
      |> Enum.map(fn sex -> {sex.name, sex.id} end)

    {:ok, assign(socket, sex_list: sex_list)}
  end

  def handle_event("save", %{"animal_sex_order" => animal_sex_order}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = AnimalSexOrders.validate(changeset.data, animal_sex_order)

    if changeset.valid? do
      case AnimalSexOrders.create_or_update_animal_sex_order(changeset.data, animal_sex_order) do
        {:ok, _animal_sex_order} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, AnimalSexOrderLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"animal_sex_order" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> AnimalSexOrders.change_animal_sex_order(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
