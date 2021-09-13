defmodule CattlePurchase.Treatments do
  alias CattlePurchase.{
    Treatment,
    Repo
  }

  import Ecto.Query, only: [from: 2]
  @topic "cattle_purchase:treatments"

  def subscribe(), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(CattlePurchase.PubSub, "#{@topic}:#{id}")

  @doc """
  List all treatments
  """

  def list_treatments() do
    Repo.all(Treatment)
  end

  def get_inactive_treatments() do
    from(p in Treatment,
      where: p.active != true
    )
    |> Repo.all()
  end

  def get_active_treatments() do
    from(p in Treatment,
      where: p.active == true
    )
    |> Repo.all()
  end

  @doc """
  Create a new treatment
  """
  def new_treatment() do
    Treatment.new_changeset(%Treatment{}, %{})
  end

  def change_treatment(%Treatment{} = treatment, attrs \\ %{}) do
    Treatment.changeset(treatment, attrs)
  end

  def validate(%Treatment{} = treatment, attrs \\ %{}) do
    treatment
    |> change_treatment(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a treatment
  """
  def create_or_update_treatment(%Treatment{} = treatment, attrs \\ %{}) do
    treatment
    |> Treatment.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:treatments, :created_or_updated])
  end

  @doc """
  Delete a purchase type
  """
  def delete_treatment(%Treatment{} = treatment) do
    Repo.delete(treatment)
    |> notify_subscribers([:treatments, :deleted])
  end

  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(CattlePurchase.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
