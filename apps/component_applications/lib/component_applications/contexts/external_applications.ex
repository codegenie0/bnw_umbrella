defmodule ComponentApplications.ExternalApplications do
  import Ecto.Query

  alias ComponentApplications.{
    ExternalApplication,
    Repo
  }

  @topic "component_applications:external_application"

  def subscribe(), do: Phoenix.PubSub.subscribe(ComponentApplications.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(ComponentApplications.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(ComponentApplications.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(ComponentApplications.PubSub, "#{@topic}:#{id}")

  def new_external_application(), do: %ExternalApplication{}

  def get_external_application!(id), do: Repo.get!(ExternalApplication, id)

  def list_external_applications() do
    ExternalApplication
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_external_application(%ExternalApplication{} = external_application, attrs \\ %{}) do
    external_application
    |> ExternalApplication.changeset(attrs)
    |> Repo.insert_or_update()
    |> notify_subscribers([:external_application, (if Ecto.get_meta(external_application, :state) == :built, do: :created, else: :updated)])
  end

  def delete_external_application(%ExternalApplication{} = external_application) do
    Repo.delete(external_application)
    |> notify_subscribers([:external_application, :deleted])
  end

  def change_external_application(%ExternalApplication{} = external_application, attrs \\ %{}) do
    ExternalApplication.changeset(external_application, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(ComponentApplications.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(ComponentApplications.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
