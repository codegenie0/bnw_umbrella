defmodule CattlePurchase.CommissionPayees do
  alias CattlePurchase.{
    CommissionPayee,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:commission_payees"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all commission_payees
  """

  def list_commission_payees() do
    Repo.all(CommissionPayee)
  end

  def get_inactive_commission_payees() do
    from(p in CommissionPayee,
      where: p.active != true
    )
    |> Repo.all()
  end

  def get_active_commission_payees() do
    from(p in CommissionPayee,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  Create a new commission_payee
  """
  def new_commission_payee() do
    CommissionPayee.new_changeset(%CommissionPayee{}, %{})
  end

  def change_commission_payee(%CommissionPayee{} = commission_payee, attrs \\ %{}) do
    CommissionPayee.changeset(commission_payee, attrs)
  end

  def validate(%CommissionPayee{} = commission_payee, attrs \\ %{}) do
    commission_payee
    |> change_commission_payee(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a commission_payee
  """
  def create_or_update_commission_payee(%CommissionPayee{} = commission_payee, attrs \\ %{}) do
    commission_payee
    |> CommissionPayee.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:commission_payees, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_commission_payee(%CommissionPayee{} = commission_payee) do
    Repo.delete(commission_payee)
    |> notify_subscribers([:commission_payees, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
