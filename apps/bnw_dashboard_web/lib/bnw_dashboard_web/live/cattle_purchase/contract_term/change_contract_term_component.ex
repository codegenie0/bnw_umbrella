defmodule BnwDashboardWeb.CattlePurchase.ContractTerms.ChangeContractTermComponent do
  @moduledoc """
  ### Live view component for the add/update contract term modal.
  """
  use BnwDashboardWeb, :live_component
  alias CattlePurchase.ContractTerms
  alias BnwDashboardWeb.CattlePurchase.ContractTerm.ContractTermLive

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("save", %{"contract_term" => contract_term}, socket) do
    %{changeset: changeset} = socket.assigns
    changeset = ContractTerms.validate(changeset.data, contract_term)

    if changeset.valid? do
      case ContractTerms.create_or_update_contract_term(changeset.data, contract_term) do
        {:ok, _contract_term} ->
          {:noreply, push_patch(socket, to: Routes.live_path(socket, ContractTermLive))}

        {:error, %Ecto.Changeset{} = changest} ->
          {:noreply, assign(socket, changeset: changest)}
      end

      {:noreply, socket}
    else
      {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"contract_term" => params}, socket) do
    %{changeset: changeset} = socket.assigns

    changeset =
      changeset.data
      |> ContractTerms.change_contract_term(params)
      |> Map.put(:action, :update)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end
end
