defmodule BnwDashboardWeb.CattlePurchase.PurchaseTypeFilters.ChangePurchaseTypeFilterComponent do
  @moduledoc """
  ### Live view component for the add/update purchase flags modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.PurchaseTypeFilters
  alias BnwDashboardWeb.CattlePurchase.PurchaseTypeFilter.PurchaseTypeFilterLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"purchase_type_filter" => purchase_type_filter}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = PurchaseTypeFilters.validate(changeset.data, purchase_type_filter)

    purchase_type_filter =
      Map.put_new(
        purchase_type_filter,
        "purchase_types_ids",
        get_purchase_type_ids(socket.assigns.active_purchase_types)
      )

    if(validate_purchase_type(socket.assigns.active_purchase_types)) do
      if changeset.valid? do
        case PurchaseTypeFilters.create_or_update_purchase_type_filter(
               changeset.data,
               purchase_type_filter
             ) do
          {:ok, _purchase_type_filter} ->
            {:noreply, push_patch(socket, to: Routes.live_path(socket, PurchaseTypeFilterLive))}

          {:error, %Ecto.Changeset{} = changest} ->
            {:noreply, assign(socket, changeset: changest, purchase_type_error: "")}
        end

        {:noreply, socket}
      else
        {:noreply, assign(socket, changeset: changeset, purchase_type_error: "")}
      end
    else
      {:noreply,
       assign(socket,
         changeset: changeset,
         purchase_type_error: "Please choose at least one Purchase Type"
       )}
    end
  end

  def handle_event("validate", %{"purchase_type_filter" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> PurchaseTypeFilters.change_purchase_type_filter(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event(
        "handle_toggle_purchase_type",
        %{"id" => _, "value" => value} = params,
        socket
      ) do
    {id, ""} = Integer.parse(params["id"])

    active_purchase_types =
      socket.assigns.active_purchase_types
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, true)
        else
          item
        end
      end)

    {:noreply, assign(socket, active_purchase_types: active_purchase_types)}
  end

  def handle_event("handle_toggle_purchase_type", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    active_purchase_types =
      socket.assigns.active_purchase_types
      |> Enum.map(fn item ->
        if(item.id == id) do
          Map.put(item, :checked, false)
        else
          item
        end
      end)

    {:noreply, assign(socket, active_purchase_types: active_purchase_types)}
  end

  defp validate_purchase_type(active_purchase_types) do
    Enum.find(active_purchase_types, false, fn item -> item.checked end)
  end

  defp get_purchase_type_ids(active_purchase_types) do
    Enum.reduce(active_purchase_types, [], fn item, acc ->
      if(item.checked) do
        acc ++ [item.id]
      else
        acc
      end
    end)
  end
end
