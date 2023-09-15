defmodule Realtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Cainophile.Adapters.Postgres,
        register: Cainophile.ExamplePublisher, # name this process will be registered globally as, for usage with Cainophile.Adapters.Postgres.subscribe/2
        epgsql: %{ # All epgsql options are supported here
          host: 'localhost',
          username: "root",
          database: "postgres",
          password: "postgres",
          port: 5432
        },
        slot: :temporary, # :temporary is also supported if you don't want Postgres keeping track of what you've acknowledged
        wal_position: {"0", "0"}, # You can provide a different WAL position if desired, or default to allowing Postgres to send you what it thinks you need
        publications: ["example_publication"]
      },
      # Start the Telemetry supervisor
      RealtimeWeb.Telemetry,
      # Start the Ecto repository
      Realtime.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Realtime.PubSub},
      # Start Finch
      {Finch, name: Realtime.Finch},
      # Start the Endpoint (http/https)
      RealtimeWeb.Endpoint
      # Start a worker by calling: Realtime.Worker.start_link(arg)
      # {Realtime.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Realtime.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RealtimeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
