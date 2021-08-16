defmodule PlugsApp.Reports do

  import Ecto.Query
  alias PlugsApp.{
    Report,
    Repo
  }

  @topic "plugs_app:reports"

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

  def list_reports(plug) do
    Report
    |> where([r], r.plug_name == ^plug)
    |> order_by([r], r.report_name)
    |> Repo.all()
  end

  def get_report(id) do
    Report
    |> where([r], r.id == ^id)
    |> Repo.one()
  end

  def get_report(id, args) do
    report = get_report(id)

    %{report_url: url} = report
    url = build_url(url, args)
    Map.put(report, :report_url, url)
  end

  def new_report() do
    %Report{}
  end

  def build_url(url, args \\ "") do
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
      true -> url <> "&j_username=bnw_dashboard_plugs_app"
    end

    cond do
      String.contains?(url, args) -> url
      true -> url <> args
    end
  end

  def change_report(%Report{} = report, attrs \\ %{}) do
    Report.changeset(report, attrs)
  end

  def validate(%Report{} = report, attrs \\ %{}) do
    report
    |> change_report(attrs)
    |> Map.put(:action, :insert)
  end

  def create_or_update_report(%Report{} = report, attrs \\ %{}) do
    report
    |> Report.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:report, :created_or_updated])
  end

  def delete_report(%Report{} = report) do
    Repo.delete(report)
    |> notify_subscribers([:report, :deleted])
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
