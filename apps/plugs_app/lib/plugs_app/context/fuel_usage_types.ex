defmodule PlugsApp.FuelUsageTypes do

  import Ecto.Query
  alias PlugsApp.{
    FuelUsageType,
    Repo
  }

  @topic "plugs_app:fuel_usage_type"


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
      %{id: id, type: type} = x
      [key: type, value: id]
    end)
  end

  def get_plug(id) do
    %{type: type} = get_plug_struct(id)
    type
  end

  def list_all_plugs() do
    FuelUsageType
    |> order_by([plug], asc: plug.type)
    |> Repo.all()
  end

  def get_plug_struct(id) do
    if is_nil(id) do
      %{type: nil}
    else
      plug = FuelUsageType
      |> where([plug], plug.id == ^id)
      |> Repo.one()
      if !is_nil(plug) do
        plug
      else
        %{type: nil}
      end
    end
  end

  def new_plug() do
    %FuelUsageType{}
  end

  def change_plug(%FuelUsageType{} = plug, attrs \\ %{}) do
    FuelUsageType.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%FuelUsageType{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%FuelUsageType{} = plug, attrs \\ %{}) do
    plug
    |> FuelUsageType.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:fuel_usage_type, :created_or_updated])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%FuelUsageType{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:fuel_usage_type, :deleted])
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
