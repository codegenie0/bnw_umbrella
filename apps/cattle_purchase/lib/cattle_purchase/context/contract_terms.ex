defmodule CattlePurchase.ContractTerms do
  alias CattlePurchase.{
    ContractTerm,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:contract_terms"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all contract_terms
  """

  def list_contract_terms() do
    Repo.all(ContractTerm)
  end

  def get_inactive_contract_terms() do
    from(p in ContractTerm,
      where: p.active != true
    )
    |> Repo.all()
  end

  def get_active_contract_terms() do
    from(p in ContractTerm,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  Create a new contract_term
  """
  def new_contract_term() do
    ContractTerm.new_changeset(%ContractTerm{}, %{})
  end

  def change_contract_term(%ContractTerm{} = contract_term, attrs \\ %{}) do
    ContractTerm.changeset(contract_term, attrs)
  end

  def validate(%ContractTerm{} = contract_term, attrs \\ %{}) do
    contract_term
    |> change_contract_term(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a contract_term
  """
  def create_or_update_contract_term(%ContractTerm{} = contract_term, attrs \\ %{}) do
    contract_term
    |> ContractTerm.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:contract_terms, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_contract_term(%ContractTerm{} = contract_term) do
    Repo.delete(contract_term)
    |> notify_subscribers([:contract_terms, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
