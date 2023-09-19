defmodule PostgresListener.Supervisor do

  use Supervisor

  alias PostgresListener.Replication
  alias PostgresListener.Events
  alias PostgresListener.Configs

  @moduledoc """
  # Application Supervisor
      # config agent -> Takes care of my app configuration and process running for my listener
      # Replication Supervisor -> takes care of my subscriber and publisher events from DB and delegate to the events module
      # Events Server -> That's the third process responsible for passing the events on to the main application
  """

  @doc """
  Sets children ( The above three processes ) for the current supervisor. Why not directly to the array? Because we need validation for the arguments provided by the user.
  """
  @impl true
  def init(opts) do
    # initiate the supervisor with given set of children and configuration
    opts |> set_children() |> Supervisor.init(strategy: :one_for_one)
  end

  @doc """
  The child spec function is responsible for conveying to elixir, "How do we want supervisor's children to start" i.e. { module, function_to_trigger, params_to_pass}. For our module, we have three processes which are all genservers, hence we need only start_link functions and we will pass on our configuration parameters to them.
  """

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end


  @doc """
  Starts the supervisor which initiates the above mentioned three processes, for listening, passing and config for the associated application
  """
  def start_link(opts) do
    validate_arguments(opts)

    # get the provided app name from the configuration
    app_name = Keyword.get(opts, :name)

    # Start the registry and set the supervisor, FOR THE CURRENT DEPENDENT APPLICATION
    { :ok, _pid } = Configs.Registry.start_registry()

    name = Configs.Registry.set_name(:set_supervisor, __MODULE__, app_name)

    Supervisor.start_link(__MODULE__, configs: opts, name: name)

  end


  defp validate_arguments(opts) do
    # parameters that we need to have
    config_params =[:hostname, :username, :password, :port, :database, :subscriptions, :publications, :modules, :name]

    # checking for missing parameter in the given configuration
    missing_params = Enum.filter(config_params, &(not Keyword.has_key?(opts, &1)))

    # if missing_params is not empty we must raise an error to the application, saying this config won't work
    if not Enum.empty?(missing_params) do
      raise "Sorry needed configuration #{missing_params}"
    end
  end

  defp set_children(opts) do
    configs = Keyword.get(opts, :configs);
    app_name = Keyword.get(configs, :name)

    config_agent = [{ Configs.Root, configs: configs }]
    replication_supervisor = [{ Replication.Supervisor, app_name: app_name }]

    # If the events module is not active then we have to initiate it.
    events_server = if is_nil(Process.whereis(Events.Root)), do: [{Events.Root, []}], else: []

    config_agent ++ replication_supervisor ++ events_server
  end

end
