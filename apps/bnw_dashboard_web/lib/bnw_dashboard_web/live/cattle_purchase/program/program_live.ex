defmodule BnwDashboardWeb.CattlePurchase.Program.ProgramLive do
  use BnwDashboardWeb, :live_view

  alias CattlePurchase.{
    Authorize,
    Programs
  }

  alias BnwDashboardWeb.CattlePurchase.Programs.ChangeProgramComponent

  defp authenticate(socket) do
    current_user = Map.get(socket.assigns, :current_user)

    cond do
      current_user && Authorize.authorize(current_user, "programs") ->
        true

      true ->
        false
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket =
      assign_defaults(session, socket)
      |> assign(
        page_title: "Active Program",
        app: "Cattle Purchase",
        program: "active",
        programs: Programs.get_active_programs(),
        modal: nil
      )

    if connected?(socket) do
      Programs.subscribe()
    end

    case authenticate(socket) do
      true -> {:ok, socket}
      false -> {:ok, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    changeset = Programs.new_program()
    socket = assign(socket, changeset: changeset, modal: :change_program)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    changeset =
      Enum.find(socket.assigns.programs, fn pt -> pt.id == id end)
      |> Programs.change_program()

    socket = assign(socket, changeset: changeset, modal: :change_program)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", params, socket) do
    {id, ""} = Integer.parse(params["id"])

    Enum.find(socket.assigns.programs, fn pt -> pt.id == id end)
    |> Programs.delete_program()

    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel", _, socket) do
    socket = assign(socket, modal: nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set-active-program", _params, socket) do
    {:noreply,
     assign(socket,
       program: "active",
       page_title: "Active Program",
       programs: Programs.get_active_programs()
     )}
  end

  @impl true
  def handle_event("set-inactive-program", _params, socket) do
    {:noreply,
     assign(socket,
       program: "inactive",
       page_title: "Inactive Program",
       programs: Programs.get_inactive_programs()
     )}
  end

  @impl true
  def handle_info({[:programs, :created_or_updated], _}, socket) do
    socket = assign(socket, modal: nil, changeset: nil)
    program = socket.assigns.program
    data = fetch_by_type(program)
    {:noreply, assign(socket, programs: data)}
  end

  @impl true
  def handle_info({[:programs, :deleted], _}, socket) do
    program = socket.assigns.program
    data = fetch_by_type(program)
    {:noreply, assign(socket, programs: data)}
  end

  defp fetch_by_type(program) do
    if program == "active",
      do: Programs.get_active_programs(),
      else: Programs.get_inactive_programs()
  end
end
