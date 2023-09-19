defmodule PostgresListener.Replication.Supervisor do
  use Supervisor

  @moduledoc """
  ## Replication Supervisor
  The module serves as a dedicated supervisor for our replication processes, i.e. Replication Publisher and Replication Supervisor, the current supervisor only start replication supervisor. Why are we taking up a different supervisor? Because the supervisor starategy we are opting is one_for_all here, if one process crashes, every process that's dependent on it must restart.
  """
  alias PostgresListener.Replication.ReplicationServer

  @impl true
  def init(opts) do
    # Set the children for the supervisor
    app_name = opts |> Keyword.get(:configs) |> Keyword.get(:app_name)
    children = [{ ReplicationServer, app_name: app_name }]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def start_link(opts) do
    app_name = Keyword.get(opts, :app_name)
    name = PostgresListener.Configs.Registry.set_name(:set_supervisor, __MODULE__, app_name)
    Supervisor.start_link(__MODULE__, configs: opts, name: name)
  end
end
