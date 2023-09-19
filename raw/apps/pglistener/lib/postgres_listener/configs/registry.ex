defmodule PostgresListener.Configs.Registry do

  @moduledoc """
  Registry module keeps the track of all of our started process, such as supervisor, replication processes and events. That's helpful when we have multiple apps running the same module, for multiple apps we have to run identical processes and registry is important to contextualize the processes, hence we are using app name to segrigate the processes.
  """

  # An atom that let's us track our registry
  @pg_registry :pg_registry

  @doc """
  Starts a global registry ( All Apps that listens to the PG_Listener ) for all of the processes together, that's why we need to check if the registry is already running, because there can be two supervisors for two different apps, but registry must be same.
  """
  def start_registry do
    # Find out if our process registry is running, if yes return the process id that is running the registry else start new and return it.
    case Process.whereis(@pg_registry) do
      nil -> Registry.start_link(keys: :unique, name: @pg_registry)
      pid -> { :ok, pid }
    end
  end

  # Set the processes for apps. You can understand it like { module + app_name } is kind of a unique identifier, that start a module for one app only once.
  def set_name(:set_agent, module, app_name), do: set_name(module, app_name)
  def set_name(:set_supervisor, module, app_name), do: set_name(:via, module, app_name)
  def set_name(:set_genserver, module, app_name), do: set_name(:via, module, app_name)


  @doc """
  Generic function used by the external api to set the process to the registry
  """
  defp set_name(module, app_name), do: {:via, Registry, {@pg_registry, {module, app_name}}}

  @doc """
  Gets an state from an agent that is responsible for fetching the process from the module & app_name.
  """
  def get_state(:get_agent, module, app_name) do
    Agent.get({:via, Registry, {:walex_registry, {module, app_name}}}, & &1)
  end

end
