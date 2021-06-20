defmodule BnwDashboardWeb.CihReportPlugs.Plugs.PlugsLive do
  @moduledoc """
  ### Live view for the CIH report plugs page.
  This document renders the main CIH report page and handles changes to it such as adding, removing, or changing a plug.
  """
  use BnwDashboardWeb, :live_view

  alias BnwDashboardWeb.CihReportPlugs.Plugs.ChangePlugComponent
  alias CihReportPlugs.{
    Authorize,
    Plugs,
    Users
  }

  # private function that authenticates a user by testing if the current user has access to view the current page.
  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)
    cond do
      current_user && Authorize.authorize(current_user, "plugs") ->
        true
      true ->
        false
    end
  end

  # This function fetches all plugs from the database and adds them to the plugs variable in the socket returned.
  defp fetch_plugs(socket) do
    plugs =
      Plugs.list_plugs()
      |> Enum.map(&(Plugs.change_plug(&1))) #replace plugs with changeset of plugs
    assign(socket, plugs: plugs)
  end

  @doc """
  This function is the entry point the live view. This is called when live_component(..., this, ...) is called
  """
  @impl true
  def mount(_, session, socket) do
    socket = assign_defaults(session, socket)
    |> fetch_plugs()
    |> assign(page_title: "BNW Dashboard · CIH Plugs",
              modal: nil,
              changeset: nil,
              app: "CIH Report Plugs",
              plug_id: 0)

    if connected?(socket) do
      Plugs.subscribe()
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
  Handle when a plug is updated or created. Removes modal. Pulls data from database.

  Handle when a plug is deleted. Pulls data from database.

  Handle when current user's permissions are updated to adjust what the user can see immediately.
  """
  @impl true
  def handle_info({[:user, :updated], _customer}, socket) do
    case authenticate(socket) do
      true -> {:noreply, socket}
      false -> {:noreply, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_info({[:plug, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    {:noreply, fetch_plugs(socket)}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
  # end handle_info

  @doc """
  Handle when the user presses the edit button for a plug. Adds the edit plug modal by setting
      socket.assigns.modal = :change_plug.

  Handle when the user presses delete. Deletes the plug then refreshes the data.

  Handle when the user presses cancel or otherwise cancels the update modal. Closes the modal without committing to database.
  """
  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    socket = assign(socket, changeset: cur, modal: :change_plug)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset =
      Plugs.new_plug()
      |> Plugs.change_plug()
    socket = assign(socket, changeset: changeset, modal: :change_plug)
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, changest: nil, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])
    cur = Enum.find(socket.assigns.plugs, fn u -> u.data.id == id end)
    Plugs.delete_plug(cur.data)
    {:noreply, socket}
  end
  # end handle_event
end
