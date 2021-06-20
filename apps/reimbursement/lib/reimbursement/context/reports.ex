defmodule Reimbursement.Reports do
  import Ecto.Query
  alias Reimbursement.{
    Report,
    Repo
  }

  import Ecto.Query

  @topic "reimbursement:reports"

  @doc """
  This function subscribes a user to changes in the reimbursement entries page.
  This allows for users to get a live update on their role within the application.
  """
  def subscribe(), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, @topic)
  def subscribe(id), do: Phoenix.PubSub.subscribe(Reimbursement.PubSub, "#{@topic}:#{id}")
  @doc """
  This function unsubscribes a user to changes in the reimbursement entries page.
  """
  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, @topic)
  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Reimbursement.PubSub, "#{@topic}:#{id}")

  @doc """
  get the currently in use report
  """
  def get_primary_report() do
    report = Report
    |> where([report], report.primary == true)
    |> Repo.one()

    if !is_nil(report) do
      %{id: id} = report
      id
    else
      -1
    end
  end

  @doc """
  get a specific report
  """
  def get_report(id) do
    Report
    |> where([report], report.id == ^id)
    |> Repo.one()
  end

  @doc """
  list all reports
  """
  def list_reports() do
    Report
    |> order_by([report], desc: report.primary)
    |> Repo.all()
  end

  @doc """
  build the url for the report adding in fields:
  user_id,
  month,
  year
  """
  def build_url(id, month, year, user) do
    %{url: url} = get_report(id)

    url = cond do
      String.contains?(url, "decorate=no") -> url
      true -> url <> "&decorate=no"
    end

    url = cond do
      String.contains?(url, "j_password") -> url
      true -> url <> "&j_password=rxFlMe4nR3mXCJA"
    end

    url = cond do
      String.contains?(url, "j_username") -> url
      true -> url <> "&j_username=reimbursement"
    end


    url = url <> "&user_id=#{user}"
    url = url <> "&month=#{month}"
    url = url <> "&year=#{year}"

    url
  end

  @doc """
  create a new report
  """
  def new_report() do
    %Report{}
  end

  @doc """
  get a changeset for a report
  """
  def change_report(%Report{} = report, attrs \\ %{}) do
    Report.changeset(report, attrs)
  end

  @doc """
  validation function used by the new report modal.
  Makes sure the url and name exist
  """
  def validate(%Report{} = report, attrs \\ %{}) do
    report
    |> change_report(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  set which report is primary
  only one report can be primary so all other reports are set to not primary

  # get all reports

  # delete them

  # add them back again but set primary to false unless id = primary_id
  """
  def set_primary(id) do
    # get all reports
    reports = list_reports()
    # delete them
    reports
      |> Enum.map(fn x ->
        Repo.delete(x)
      end)
    # add them back again but set primary to false unless id = primary_id
    reports
      |> Enum.map(fn x ->
      %{id:     this_id,
        name:   name,
        url:    url,
        active: active} = x
      Repo.insert(%Report{id:      this_id,
                          active:  active,
                          name:    name,
                          url:     url,
                          primary: String.to_integer(id) == this_id})
      |> notify_subscribers([:report, :created_or_updated])
      end)
  end

  @doc """
  toggle active for a report

  # get the report

  # get values from the report

  # delete the report

  # insert the modified report
  """
  def set_active(id) do
    # get the report
    report =
      Report
      |> where([report], report.id == ^id)
      |> Repo.one()

    # get values from the report
    %{id:      this_id,
      name:    name,
      url:     url,
      active:  active,
      primary: primary} = report

    # delete the report
    delete_report(report)

    # insert the modified report
    Repo.insert(%Report{id: this_id,
                        active: !active,
                        name: name,
                        url: url,
                        primary: primary})
    |> notify_subscribers([:report, :created_or_updated])
  end

  @doc """
  Create or update a specific report, Called by the create update modal
  """
  def create_or_update_report(%Report{} = report, attrs \\ %{}) do
    report
    |> Report.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:report, :created_or_updated])
  end

  @doc """
  Delete a report from the list
  """
  def delete_report(%Report{} = report) do
    Repo.delete(report)
    |> notify_subscribers([:report, :delete])
  end

  # Notify all subscribers of a change
  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Reimbursement.PubSub, "#{@topic}:#{result.id}", {event, result})

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
