defmodule PostgresListener.Configs.Root do

  @moduledoc """
  An agent that takes care of the configuration for the specific app, for more than one app there would be more than one agents taking care of them as well.
  """

  alias PostgresListener.Configs.Registry

  use Agent

  @doc """
  Takes the opts for an app instance and sets the config as a state to the agent, along with registering self as an agent to the registry module.
  """
  def start_link(opts) do
    configs = opts |> Keyword.get(:configs)
    app_name = Keyword.get(configs, :name)
    name = Registry.set_name(:set_agent, __MODULE__, app_name)
    Agent.start_link(&(configs), name: name)
  end


  @doc """
  Returns the configuration for a particular app from the registry. The registry fetches the current agent responsible for the current app with the __MODULE__ and the appname and then returns the current state from it.
  """
  def get_configs(app_name, keys \\ []) when is_list(keys) do
    configs = WalEx.Registry.get_state(:get_agent, __MODULE__, app_name)
    if Enum.empty?(keys), do: configs, else: Keyword.take(configs, keys)
  end

end
