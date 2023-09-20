defmodule Planerealtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Planerealtime.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Planerealtime.PubSub},
      # Start Finch
      {Finch, name: Planerealtime.Finch}
      # Start a worker by calling: Planerealtime.Worker.start_link(arg)
      # {Planerealtime.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Planerealtime.Supervisor)
  end
end
