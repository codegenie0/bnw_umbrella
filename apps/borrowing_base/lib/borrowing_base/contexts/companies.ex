defmodule BorrowingBase.Companies do
  import Ecto.Query

  alias BorrowingBase.{
    Company,
    Repo,
    Role
  }

  @topic "borrowing_base:company"

  def subscribe(), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(BorrowingBase.PubSub, "#{@topic}:#{id}")

  def new_company(), do: %Company{}

  def get_company!(id), do: Repo.get!(Company, id)

  def list_companies() do
    Company
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_or_update_company(%Company{} = company, attrs \\ %{}) do
    {result, new_company} = company
    |> Company.changeset(attrs)
    |> Repo.insert_or_update()

    if result == :ok && is_nil(company.id) do
      Repo.insert! %Role{
        name: "#{new_company.name} Admin",
        company_admin: true,
        company_id: new_company.id
      }
    end

    notify_subscribers({result, new_company}, [:company, :updated])
  end

  def delete_company(%Company{} = company) do
    Repo.delete(company)
    |> notify_subscribers([:company, :deleted])
  end

  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(BorrowingBase.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
