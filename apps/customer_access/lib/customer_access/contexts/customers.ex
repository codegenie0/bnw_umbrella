defmodule CustomerAccess.Customers do
  import Ecto.Query
  import Ecto.Changeset

  alias CustomerAccess.{
    Customer,
    Repo
  }

  @topic "accounts:users"

  def subscribe(), do: Phoenix.PubSub.subscribe(Accounts.PubSub, @topic)

  def subscribe(id), do: Phoenix.PubSub.subscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def unsubscribe(), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, @topic)

  def unsubscribe(id), do: Phoenix.PubSub.unsubscribe(Accounts.PubSub, "#{@topic}:#{id}")

  def new_user(), do: %Customer{}

  def get_customer(id) do
    Customer
    |> Repo.get(id)
    |> Repo.preload(:customer_report_types)
    |> Repo.preload(:report_types)
  end

  def get_customer!(id) do
    Customer
    |> Repo.get!(id)
    |> Repo.preload(:customers_report_types)
    |> Repo.preload(:report_types)
  end

  def get_customer_by(var, val) do
    Customer
    |> Repo.get_by([{var, val}])
    |> Repo.preload(:report_types)
  end

  def list_customers(current_page \\ 1, per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    Customer
    |> where([user], user.customer and
      (like(user.username, ^search) or
       like(user.name, ^search) or
       like(user.email, ^search)))
    |> order_by([user], fragment("ABS(?)", user.username))
    |> offset(^(per_page * (current_page - 1)))
    |> limit(^per_page)
    |> Repo.all()
  end

  def total_pages(per_page \\ 10, search \\ "") do
    search = "%#{search}%"
    customer_count = Customer
    |> where([user], user.customer and
      (like(user.username, ^search) or
       like(user.name, ^search) or
       like(user.email, ^search)))
    |> Repo.aggregate(:count, :id)

    (customer_count / per_page)
    |> Decimal.from_float()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  def create_or_update_customer(%Customer{} = user, attrs \\ %{}) do
    report_types = Map.get(attrs, "report_types_ids", [])
    |> Enum.map(fn {k, _v} -> %{report_type_id: String.to_integer(k)} end)
    attrs = Map.put(attrs, "customers_report_types", report_types)
    changeset = Customer.changeset(user, attrs)

    {_, email} = fetch_field(changeset, :email)

    cond do
      is_nil(email) || email == "" ->
        force_change(changeset, :allow_password_reset, false)
      true ->
        changeset
    end
    |> Repo.insert_or_update()
    |> notify_subscribers([:user, (if Ecto.get_meta(user, :state) == :built, do: :created, else: :updated)])
    |> notify_subscribers([:customer, (if Ecto.get_meta(user, :state) == :built, do: :created, else: :updated)])
  end

  def delete_customer(%Customer{} = user) do
    Repo.delete(user)
    |> notify_subscribers([:user, :deleted])
    |> notify_subscribers([:customer, :deleted])
  end

  def change_customer(%Customer{} = user, attrs \\ %{}) do
    Customer.changeset(user, attrs)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Accounts.PubSub, @topic, {event, result})
    Phoenix.PubSub.broadcast(Accounts.PubSub, "#{@topic}:#{result.id}", {event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
