defmodule TentativeShip.Customers do
  import Ecto.Query

  alias TentativeShip.{
    Customer,
    Repo
  }

  @topic "tentative_ship:customers"

  def subscribe(), do: Phoenix.PubSub.subscribe(TentativeShip.PubSub, @topic)

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(TentativeShip.PubSub, @topic)

  def get_customer!(id), do: Repo.get!(Customer, id)

  def list_customers(current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    Customer
    |> where([c], like(c.name, ^search) or like(c.customer_number, ^search))
    |> order_by([c], fragment("cast(? as unsigned)", c.customer_number))
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  def total_pages(per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    customer_count =
      Customer
      |> where([c], like(c.name, ^search) or like(c.customer_number, ^search))
      |> Repo.aggregate(:count, :id)

    (customer_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end


  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end

  # Update all customers from turnkey.
  # Customer.id is Turnkey's associate_number
  def update_customers() do
    new_customers = new_customers()
    updated_customers = updated_customers()
    deleted_customers = deleted_customers()
    delete_query = from(c in Customer, where: c.id in ^deleted_customers)

    Enum.reduce(updated_customers, Ecto.Multi.new(), fn c, multi ->
      Ecto.Multi.update(multi, {:customer, c.customer.id}, change_customer(c.customer, %{"name" => c.new_name}))
    end)
    |> Ecto.Multi.insert_all(:insert_all, Customer, new_customers)
    |> Ecto.Multi.delete_all(:delete_all, delete_query)
    |> Repo.transaction()
    |> notify_subscribers([:customers, :updated])
  end

  defp new_customers() do
    from(tkc in "cusmas")
    |> join(:left, [tkc], c in Customer, on: tkc.associate_number == c.customer_number)
    |> where([tkc, c], tkc.yard == ^"cas" and is_nil(c.id))
    |> select([tkc, c], %{id: tkc.associate_number, name: tkc.name, customer_number: tkc.associate_number})
    |> Repo.Turnkey.all()
    |> Enum.map(&(%{id: &1.id, name: &1.name, customer_number: "#{&1.customer_number}"}))
  end

  defp updated_customers() do
    from(tkc in "cusmas")
    |> join(:left, [tkc], c in Customer, on: tkc.associate_number == c.customer_number and tkc.name != c.name)
    |> where([tkc, c], tkc.yard == ^"cas" and not is_nil(c.id))
    |> select([tkc, c], %{customer: %Customer{id: c.id, name: c.name, customer_number: c.customer_number}, new_name: tkc.name})
    |> Repo.Turnkey.all()
  end

  defp deleted_customers() do
    from(tkc in "cusmas")
    |> join(:right, [tkc], c in Customer,
      on: tkc.associate_number == c.customer_number and tkc.yard == ^"cas")
    |> where([tkc, c], is_nil(tkc.associate_number))
    |> select([tkc, c], c.id)
    |> Repo.Turnkey.all()
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(TentativeShip.PubSub, @topic, {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
