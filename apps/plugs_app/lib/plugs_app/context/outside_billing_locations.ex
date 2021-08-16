defmodule PlugsApp.OutsideBillingLocations do

  import Ecto.Query
  alias PlugsApp.{
    OutsideBillingLocation,
    Repo
  }

  @topic "plugs_app:outside_billing_location"


  @doc """
  This function subscribes a user to changes in the ocb_report_plugs plugs page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(PlugsApp.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(PlugsApp.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in the ocb_report_plugs plugs page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(PlugsApp.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(PlugsApp.PubSub, "#{@topic}:#{id}")

  @doc """
  Get all plugs from the database.
  """
  def list_plugs() do
    list_all_plugs()
    |> Enum.map(fn x->
      %{id: id, location: location} = x
      [key: location, value: id]
    end)
  end

  def list_plugs(customer) do
    list_all_plugs(customer)
    |> Enum.map(fn x->
      %{id: id, location: location} = x
      [key: location, value: id]
    end)
  end

  def get_plug(id) do
    %{location: location} = get_plug_struct(id)
    location
  end

  def get_customer(id) do
    %{customer: customer} = get_plug_struct(id)
    customer
  end

  def list_all_plugs() do
    OutsideBillingLocation
    |> order_by([plug], [asc: plug.customer, asc: plug.location])
    |> Repo.all()
  end

  def list_all_plugs(customer) do
    if is_nil(customer) do
      []
    else
      OutsideBillingLocation
      |> order_by([plug], asc: plug.location)
      |> where([plug], plug.customer == ^customer)
      |> Repo.all()
    end
  end

  def get_plug_struct(id) do
    if is_nil(id) do
      %{location: nil}
    else
      plug = OutsideBillingLocation
      |> where([plug], plug.id == ^id)
      |> Repo.one()
      if !is_nil(plug) do
        plug
      else
        %{location: nil}
      end
    end
  end

  def new_plug() do
    %OutsideBillingLocation{}
  end

  def change_plug(%OutsideBillingLocation{} = plug, attrs \\ %{}) do
    OutsideBillingLocation.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%OutsideBillingLocation{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%OutsideBillingLocation{} = plug, attrs \\ %{}) do
    plug
    |> OutsideBillingLocation.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:outside_billing_location, :created_or_updated])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%OutsideBillingLocation{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:outside_billing_location, :deleted])
  end

  @doc """
  Tell everyone who is subscribed about a change.
  """
  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end
  def notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
