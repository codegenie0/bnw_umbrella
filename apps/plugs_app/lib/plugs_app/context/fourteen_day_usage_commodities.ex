defmodule PlugsApp.FourteenDayUsageCommodities do

  import Ecto.Query
  alias PlugsApp.{
    FourteenDayUsageCommodity,
    FourteenDayUsages,
    Repo
  }

  @topic "plugs_app:fourteen_day_usage_commodity"


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
  def list_plugs(yard) do
    list_all_plugs(yard)
    |> Enum.map(fn x->
      %{
        id: id,
        commodity_name: commodity_name,
        commodity_number: commodity_number
      } = x
      [key: Integer.to_string(commodity_number) <> ": " <> commodity_name, value: id]
    end)
  end

  def get_plug(id) do
    %{
      commodity_name: commodity_name,
      commodity_number: commodity_number
    } = get_plug_struct(id)
    cond do
      !is_nil(commodity_name) && !is_nil(commodity_number) ->
        Integer.to_string(commodity_number) <> ": " <> commodity_name
      !is_nil(commodity_name) ->
        commodity_name
      !is_nil(commodity_number) ->
        commodity_number
      true ->
        ""
    end
  end

  def list_all_plugs(yard) do
    FourteenDayUsageCommodity
    |> where([plug], plug.yard == ^yard)
    |> order_by([plug], asc: plug.commodity_number)
    |> Repo.all()
  end

  def get_plug_struct(id) do
    if is_nil(id) do
      %{commodity_name: nil, commodity_number: nil}
    else
      plug = FourteenDayUsageCommodity
      |> where([plug], plug.id == ^id)
      |> Repo.one()
      if !is_nil(plug) do
        plug
      else
        %{commodity_name: nil, commodity_number: nil}
      end
    end
  end

  def new_plug() do
    %FourteenDayUsageCommodity{}
  end

  def change_plug(%FourteenDayUsageCommodity{} = plug, attrs \\ %{}) do
    FourteenDayUsageCommodity.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%FourteenDayUsageCommodity{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%FourteenDayUsageCommodity{} = plug, attrs \\ %{}) do

    plug = plug
    |> FourteenDayUsageCommodity.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:fourteen_day_usage_commodity, :created_or_updated])

    case plug do
      {:ok, plug} ->
        %{id: id, yard: yard} = plug

        changeset = FourteenDayUsages.new_plug()
        |> FourteenDayUsages.change_plug()
        FourteenDayUsages.create_or_update_plug(changeset.data, %{"commodity" => id, "yard" => yard}, true)
      _ ->
        nil
    end

    plug
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%FourteenDayUsageCommodity{} = plug) do

    %{id: id} = plug

    FourteenDayUsages.delete_plug(id)
    Repo.delete(plug)
    |> notify_subscribers([:fourteen_day_usage_commodity, :deleted])
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
