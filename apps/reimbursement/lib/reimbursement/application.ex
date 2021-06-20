defmodule Reimbursement.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Reimbursement.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Reimbursement.PubSub}
      # Start a worker by calling: Reimbursement.Worker.start_link(arg)
      # {Reimbursement.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Reimbursement.Supervisor)
  end
end
