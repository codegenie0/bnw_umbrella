defmodule CustomerAccess.DataPipeline do
  @moduledoc """
  Handles updating customers from Turnkey.
  Automatically runs at a specific time.
  """

  use Task

  import Ecto.Query

  alias CustomerAccess.{
    Customer,
    Customers,
    Repo
  }

  # customer_access.application.ex starts
  def start_link(_arg) do
    current_time = Time.utc_now()
    {_, start_time} = Time.new(5, 0, 0, 0) #start time 9pm PST (10pm PDT)
    wait_time = Time.diff(start_time, current_time, :millisecond)
    wait_time = cond do
      wait_time < 0 -> 86400000 + wait_time #if already past start time wait till the next day
      true -> wait_time
    end

    Task.start_link(__MODULE__, :poll, [%{wait_time: wait_time}])
  end

  def poll(arg) do
    %{wait_time: wait_time} = arg

    receive do
    after
      wait_time ->
        update_customers()
        # wait one day and run again
        poll(%{wait_time: 86400000})
    end
  end

  def update_customers() do
    customer_users = Customer
    |> select([user], %{username: user.username, email: user.email})
    |> where([user], user.customer)
    |> Repo.all()

    customer_emails = Enum.map(customer_users, &(String.downcase(&1.email || "")))
    |> Enum.uniq()
    customer_users = Enum.map(customer_users, &(&1.username))

    from(cusmas in "cusmas")
    |> select([cusmas], %{
        associate_number: cusmas.associate_number,
        name: cusmas.name,
        email: cusmas.email,
        web_password: cusmas.web_password
      })
    |> where([cusmas], not is_nil(cusmas.web_password) and cusmas.associate_number not in ^customer_users)
    |> group_by([cusmas], [cusmas.associate_number, cusmas.web_password])
    |> Repo.Turnkey.all()
    |> Enum.each(fn c ->
      Customers.create_or_update_customer(%Customer{}, %{
        "username" => "#{c.associate_number}",
        "name" => c.name,
        "email" => (if c.email && String.contains?(c.email, "@") && !Enum.member?(customer_emails, String.downcase(c.email)), do: String.downcase(c.email), else: nil),
        "password" => "#{c.web_password}",
        "allow_password_reset" => true,
        "customer" => true
      })
    end)
  end
end
