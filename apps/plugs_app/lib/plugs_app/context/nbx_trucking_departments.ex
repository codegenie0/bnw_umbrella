defmodule PlugsApp.NbxTruckingDepartments do

  import Ecto.Query
  alias PlugsApp.{
    NbxTruckingDepartment,
    Repo
  }

  @topic "plugs_app:nbx_trucking_department"


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
    Repo.all(NbxTruckingDepartment)
    |> Enum.map(fn x->
      %{id: id, department: department} = x
      [key: department, value: id]
    end)
  end

  def get_plug(id) do
    plug = NbxTruckingDepartment
    |> where([plug], plug.id == ^id)
    |> Repo.one()
    %{department: department} = plug
    department
  end

  def new_plug() do
    %NbxTruckingDepartment{}
  end

  def change_plug(%NbxTruckingDepartment{} = plug, attrs \\ %{}) do
    NbxTruckingDepartment.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%NbxTruckingDepartment{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%NbxTruckingDepartment{} = plug, attrs \\ %{}) do
    plug
    |> NbxTruckingDepartment.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:nbx_trucking_department, :created_or_updated])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%NbxTruckingDepartment{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:nbx_trucking_department, :deleted])
  end

  @doc """
  Tell everyone who is subscribed about a change.
  """
  def notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(PlugsApp.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end
end
