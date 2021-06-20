defmodule BnwDashboardWeb.Reimbursement.Rates.RatesLive do
  @moduledoc """
  ### Live view for Reimbursement Rates page.
  This document renders and controls the Rates page for the reimbursement application. This page is only accessable to admins
  """

  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.Reimbursement.Rates.ChangeRateComponent
  alias Reimbursement.{
    Authorize,
    Rates,
    Users
  }

  # private function that authenticates a user by testing if the current user has access to view the current page.
  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "rate") ->
        true
      true ->
        false
    end
  end

  # This function fetches all rates from the database and adds them to the rates variable in the socket returned
  defp fetch_rates(socket) do
    rates =
      Rates.list_rates()
      |> Enum.map(&(Rates.change_rate(&1))) # replace rate with changeset of rate
    assign(socket, rates: rates)
  end

  # This function recursively sets up the available years
  # A year is available if it is within depth years from current year
  # and does not currently have a value assigned to it
  defp set_up_years(socket, depth \\ 2) do
    cond do
      depth >= 0 ->
        %{available_years: years} = socket.assigns
        cur_year = Date.utc_today().year

        item = [key: Integer.to_string(cur_year + depth), value: Integer.to_string(cur_year + depth)]
        years = if Rates.get_rate(cur_year + depth) do
          years
        else
          List.insert_at(years, 0, item)
        end

        assign(socket, available_years: years)
        |> set_up_years(depth - 1)
      true ->
        socket
    end
  end

  @doc """
  This function is the entry point of the live view.
  """
  @impl true
  def mount(_, session, socket) do
    cur_date = Date.utc_today()

    socket = assign_defaults(session, socket)
      |> assign(page_title: "BNW Dashboard · Mileage Rates",
                modal: nil,
                changeset: nil,
                available_years: [],
                year: cur_date.year,
                app: "Reimbursement")
      |> fetch_rates()
      |> set_up_years()
    if connected?(socket) do
      Rates.subscribe()
      Users.subscribe()
    end
    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @doc """
  This fixes an error where the page is loaded with a parameter.
  When a button is pressed it puts a '#' in the address bar which fires this function.
  """
  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @doc """
  Handle Info.
  This page has two events that it listens to
  ### Rate created or updated
  This event refreshes the list of rates when one is changed or added.
  ### User updated
  This is called when the current users role is updated.
  When the role is updated confirm that this user can still access this page.
  If current user can access this page do nothing.
  If current user cannot access this page redirect to root.
  ### Generic handler to prevent an error.
  This handler does nothing but acknowledges all handle_info pub subs
  """
  ### Rate created or updated
  # This event refreshes the list of rates when one is changed or added.
  @impl true
  def handle_info({[:rate, :created_or_updated], _}, socket) do
    socket = assign(socket,
                    modal: nil,
                    changeset: nil,
                    available_years: [])
      |> set_up_years()
    {:noreply, fetch_rates(socket)}
  end

  ### User updated
  # This is called when the current users role is updated.
  # When the role is updated confirm that this user can still access this page.
  # If current user can access this page do nothing.
  # If current user cannot access this page redirect to root.
  @impl true
  def handle_info({[:user, :updated], _}, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  ### Generic handler to prevent an error.
  # This handler does nothing but acknowledges all handle_info pub subs
  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changeset: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.rates, fn u->u.data.id == id end)
    socket = assign(socket, changeset: cur, modal: :change_rate)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      Rates.new_rate()
      |> Rates.change_rate()
    socket = assign(socket,
                    changeset: changeset,
                    modal: :new_rate,
                    available_years: [])
    |> set_up_years()
    {:noreply, socket}
  end
end
