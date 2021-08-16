defmodule PlugsApp.CompanyVehicleMileFiscalYears do

  import Ecto.Query
  alias PlugsApp.{
    CompanyVehicleMileFiscalYear,
    Repo
  }

  @topic "plugs_app:company_vehicle_mile_fiscal_year"


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
      %{id: id, starting_year: starting_year} = x
      [key: starting_year, value: id]
    end)
  end

  def get_plug(id) do
    %{starting_year: starting_year} = get_plug_struct(id)
    Integer.to_string(starting_year) <> "-" <> Integer.to_string(starting_year + 1)
  end

  def list_all_plugs() do
    CompanyVehicleMileFiscalYear
    |> order_by([plug], asc: plug.starting_year)
    |> Repo.all()
    |> Enum.map(fn x ->
      %{id: id, starting_year: starting_year} = x
      %{
        id: id,
        starting_year: Integer.to_string(starting_year) <> "-" <> Integer.to_string(starting_year + 1)
      }
    end)
  end

  def get_plug_by_year(cur_date) do
    if is_nil(cur_date) do
      0
    else
      year =
      if cur_date.month > 10 do
        cur_date.year
      else
        cur_date.year - 1
      end
      plug = CompanyVehicleMileFiscalYear
      |> where([plug], plug.starting_year == ^year)
      |> Repo.one()
      cond do
        plug ->
          %{id: id} = plug
          id
        true ->
          0
      end
    end
  end

  def get_plug_struct(id) do
    if is_nil(id) do
      %{starting_year: nil}
    else
      plug = CompanyVehicleMileFiscalYear
      |> where([plug], plug.id == ^id)
      |> Repo.one()
      if !is_nil(plug) do
        plug
      else
        %{starting_year: nil}
      end
    end
  end

  def new_plug() do
    %CompanyVehicleMileFiscalYear{}
  end

  def change_plug(%CompanyVehicleMileFiscalYear{} = plug, attrs \\ %{}) do
    CompanyVehicleMileFiscalYear.changeset(plug, attrs)
  end

  @doc """
  Validation function used by the modal. Verifies valid date
  """
  def validate(%CompanyVehicleMileFiscalYear{} = plug, attrs \\ %{}) do
    plug
    |> change_plug(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Create or update a specifc plug. Called by the create update modal.
  """
  def create_or_update_plug(%CompanyVehicleMileFiscalYear{} = plug, attrs \\ %{}) do
    plug
    |> CompanyVehicleMileFiscalYear.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:company_vehicle_mile_fiscal_year, :created_or_updated])
  end

  @doc """
  Delete a plug then notify others of its departure
  """
  def delete_plug(%CompanyVehicleMileFiscalYear{} = plug) do
    Repo.delete(plug)
    |> notify_subscribers([:company_vehicle_mile_fiscal_year, :deleted])
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
