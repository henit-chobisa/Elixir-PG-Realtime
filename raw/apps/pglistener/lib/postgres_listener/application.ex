defmodule PostgresListener.Application do

  use Application

  @moduledoc """
  # Application Supervisor
      # config -> Takes care of my app configuration and process running for my listener
      # Replication -> takes care of my subscriber and publisher events from DB and delegate to the events module
      # Events -> That's the third process responsible for passing the events on to the main application
  """

  @impl true
  def start(_type, _args) do

    children = [

    ]

    opts = [strategy: :one_for_one, name: PostgresListener.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
