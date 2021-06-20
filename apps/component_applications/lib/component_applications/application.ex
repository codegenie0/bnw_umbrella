defmodule ComponentApplications.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ComponentApplications.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ComponentApplications.PubSub}
      # Start a worker by calling: ComponentApplications.Worker.start_link(arg)
      # {ComponentApplications.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ComponentApplications.Supervisor)
  end
end
