defmodule TentativeShip.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      TentativeShip.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TentativeShip.PubSub}
      # Start a worker by calling: TentativeShip.Worker.start_link(arg)
      # {TentativeShip.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TentativeShip.Supervisor)
  end
end
