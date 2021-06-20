defmodule CattlePurchase.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CattlePurchase.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: CattlePurchase.PubSub}
      # Start a worker by calling: CattlePurchase.Worker.start_link(arg)
      # {CattlePurchase.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: CattlePurchase.Supervisor)
  end
end
