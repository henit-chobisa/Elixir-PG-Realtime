defmodule PostgresListener.Replication.ReplicationServer do

  @moduledoc """
  # Replication Server
  ## Purpose
  Serves as a Postgres Replication Node, as soon as Postgres recieves an update from a particular replication, it publishes an update to the replication nodes, so that we can maintain a backup for the data, here we don't have to backup but we have to transmit the data across our subscribers.

  ## Working of the Replication Server
  The Current Module catches Write Ahead Log from the Postgres Database, which are responsible for logging every operation in the database. The Replication Server Catches those logs and transmits those to the publisher which then transmits the messages to the modules those are listenings to events.
  ## Types of Messages
  Refer: https://postgrespro.com/docs/postgresql/15/protocol-logicalrep-message-formats
  There are two types of data types we are handling here in server, Wal Messages ( starts with ?w) which are WAL Messages for any update / insert / delete events and the others are control messages ( ?k ) which are responsible for Synchronization of messages, what operation happened after what.
  """
  use Postrex.ReplicationConnection
  alias PostgresListener.Replication.ReplicationPublisher
  alias PostgresListener.Configs.Registry

  def start_link(opts) do
    # opts only contains app_name here, check replication supervisor, we could have passed the config for the whole app here, but you see the supervisor is holding up multiple replication connection options for different apps.
    app_name = Keyword.get(opts, :app_name)
    opts = set_pgx_replication_connection_opts(app_name)
    replications_name = [name: Registry.set_name(:set_gen_server, __MODULE__, app_name)]

    pgx_opts = opts ++ replications_name

    Postgrex.ReplicationConnection.start_link(__MODULE__, [app_name: app_name], pgx_opts)
  end


  @doc """
  Fetches configuration from the registry and constructs structure for the pgx connection handler to connect with.
  """
  def set_pgx_replication_connection_opts(app_name) do
    database_configs_keys = [:hostname, :username, :password, :port, :database]
    extra_opts = [auto_reconnect: true]
    database_configs = PostgresListener.Configs.Root.get_configs(app_name, database_configs_keys)
    extra_opts ++ database_configs
  end


  @impl true
  def init(opts) do
    app_name = opts |> Keyword.get(:app_name)
    if is_nil(Process.whereis(ReplicationPublisher)) do
      {:ok, _pid} = ReplicationPublisher.start_link([])
    end

    {:ok, %{step: :disconnected, app_name: app_name}}
  end

  @doc """
  Handles connection to the replication slot in postgres
  """
  @impl true
  def handle_connect(state) do
    temp_slot = "walex_temp_slot_" <> Integer.to_string(:rand.uniform(9_999))

    query = "CREATE_REPLICATION_SLOT #{temp_slot} TEMPORARY LOGICAL pgoutput NOEXPORT_SNAPSHOT;"

    {:query, query, %{state | step: :create_slot}}
  end

  @doc """
  Handles result from the postgres replication slot connection
  """
  @impl true
  def handle_result([%Postgrex.Result{rows: rows} | _results], %{step: :create_slot} = state) do
    slot_name = rows |> hd |> hd

    publication =
      state.app_name
      |> PostgresListener.Configs.Root.get_configs([:publication])
      |> Keyword.get(:publication)

    query =
      "START_REPLICATION SLOT #{slot_name} LOGICAL 0/0 (proto_version '1', publication_names '#{publication}')"

    {:stream, query, [], %{state | step: :streaming}}
  end

  @doc """
  Handle Wal Messages, insert / update / delete message from the postgres server
  """
  @impl true
  def handle_data(<<?w, _wal_start::64, _wal_end::64, _clock::64, rest::binary>>, state) do
    rest
    |> Decoder.decode_message()
    |> ReplicationPublisher.process_message(state.app_name)

    {:noreply, state}
  end

  @doc """
  Handles the control messages, for synchronization purposes
  """
  def handle_data(<<?k, wal_end::64, _clock::64, reply>>, state) do
    messages =
      case reply do
        1 -> [<<?r, wal_end + 1::64, wal_end + 1::64, wal_end + 1::64, current_time()::64, 0>>]
        0 -> []
      end

    {:noreply, messages, state}
  end

  @epoch DateTime.to_unix(~U[2000-01-01 00:00:00Z], :microsecond)
  defp current_time, do: System.os_time(:microsecond) - @epoch
end
