defmodule BorrowingBase.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BorrowingBase.Repo,
      BorrowingBase.Repo.Turnkey,
      BorrowingBase.Repo.InformationSchema,
      # Start the PubSub system
      {Phoenix.PubSub, name: BorrowingBase.PubSub}
      # Start a worker by calling: BorrowingBase.Worker.start_link(arg)
      # {BorrowingBase.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BorrowingBase.Supervisor)
  end
end
