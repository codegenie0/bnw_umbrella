defmodule BnwDashboardWeb.Layout.SidebarComponent do
  use BnwDashboardWeb, :live_component

  alias ComponentApplications.Authorize

  @impl true
  def mount(socket) do
    if connected?(socket) do
      Accounts.Users.subscribe()
    end
    {:ok, socket}
  end

  @impl true
  def preload(assigns) do
    set_sidebar(assigns)
  end

  defp set_sidebar(assigns) do
    [%{current_user: current_user}] = assigns

    %{
      internal_applications: internal_applications,
      external_applications: external_applications
    } = Authorize.list_pages(current_user)

    external_applications = cond do
      current_user.it_admin -> external_applications ++ [%{name: "Telemetry", url: "/dashboard"}]
      true -> external_applications
    end

    assigns
    |> Enum.map(&Map.put(&1, :internal_applications, internal_applications))
    |> Enum.map(&Map.put(&1, :external_applications, external_applications))
  end


  @impl true
  def handle_event("select_app", %{"name" => name}, socket) do
    current_app = Map.get(socket.assigns, :app)

    socket = cond do
      name == current_app ->
        assign(socket, app: nil)
      true ->
        assign(socket, app: name)
    end

    {:noreply, socket}
  end
end
