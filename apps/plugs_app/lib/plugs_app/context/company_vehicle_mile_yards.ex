defmodule PlugsApp.CompanyVehicleMileYards do

  import Ecto.Query
  alias PlugsApp.{
    CompanyVehicleMileYard,
    Repo
  }

  @topic "plugs_app:company_vehicle_mile_yard"


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
      %{id: id, yard: yard} = x
      [key: yard, value: id]
    end)
  end

  def get_plug(id) do
    %{yard: yard} = get_plug_struct(id)
    yard
  end

  def list_all_plugs() do
    CompanyVehicleMileYard
    |> order_by([plug], asc: plug.yard)
    |> Repo.all()
  end

  def get_plug_struct(id) do
    if is_nil(id) do
      %{yard: nil}
    else
      plug = CompanyVehicleMileYard
      |> where([plug], plug.id == ^id)
      |> Repo.one()
      if !is_nil(plug) do
        plug
      else
        %{yard: nil}
      end
    end
  end

  def new_plug() do
    %CompanyVehicleMileYard{}
  end

  def change_plug(%CompanyVehicleMileYard{} = plug, attrs \\ %{}) do
    CompanyVehicleMileYard.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%CompanyVehicleMileYard{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%CompanyVehicleMileYard{} = plug, attrs \\ %{}) do
    plug
    |> CompanyVehicleMileYard.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:company_vehicle_mile_yard, :created_or_updated])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%CompanyVehicleMileYard{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:company_vehicle_mile_yard, :deleted])
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
