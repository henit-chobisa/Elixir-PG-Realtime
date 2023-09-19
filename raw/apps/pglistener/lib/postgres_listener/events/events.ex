defmodule PostgresListener.Events.Root do

  use GenServer

  @moduledoc """
  The particular modules serves as a "SPEAKER" to the apps that rely on the PGListener. In the main configuration, we have mentioned the set of modules that we have to send data to on any change. The events module recieves the txn data and trigger the process function of those modules and send them the data.
  """

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end


  def process(txn, server) do
    GenServer.call(__MODULE__, {:process, txn, server}, :infinity)
  end

  @impl true
  def handle_call({:process, txn, server}, _from, state) do
    server |> PostgresListener.Configs.Root.get_configs([:modules]) |> process_events(txn)
    {:reply, :ok, state}
  end

  defp process_events([modules: modules], txn) when is_list(modules) do
    Enum.each(modules, fn module -> module.process(txn) end)
  end

  defp process_events([modules: module], txn), do: module.process(txn)

  defp process_events(nil, %{changes: [], commit_timestamp: _}), do: nil


end
