defmodule PlanerealtimeWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PlanerealtimeWeb.Telemetry,
      # Start the Endpoint (http/https)
      PlanerealtimeWeb.Endpoint,
      # Start a worker by calling: PlanerealtimeWeb.Worker.start_link(arg)
      # {PlanerealtimeWeb.Worker, arg}
      {PostgresListener.Supervisor, Application.get_env(:planerealtime_web, PostgresListener)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlanerealtimeWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlanerealtimeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
