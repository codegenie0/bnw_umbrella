defmodule BnwDashboard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BnwDashboard.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BnwDashboard.PubSub}
      # Start a worker by calling: BnwDashboard.Worker.start_link(arg)
      # {BnwDashboard.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BnwDashboard.Supervisor)
  end
end
