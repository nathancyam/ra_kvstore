defmodule RaKvstore.State do
  @moduledoc false

  @behaviour :ra_machine

  require Logger

  defstruct state: %{}, registry: [], down: [], timer_ref: nil

  @impl :ra_machine
  def init(registry) do
    %__MODULE__{registry: Map.get(registry, :nodes)}
  end

  def read_store(%__MODULE__{state: state}, key) do
    Map.get(state, key)
  end

  defp update_store(%__MODULE__{state: state} = module, key, value) do
    %{module | state: Map.put(state, key, value)}
  end

  # defp add_down_node(%__MODULE__{down: down} = state, node) do
  #   %{state | down: [node | down]}
  # end

  # defp down?(%__MODULE__{down: down}, node) do
  #   Enum.member?(down, node)
  # end

  # defp clear_down_node(%__MODULE__{down: down} = state, node) do
  #   %{state | down: List.delete(down, node)}
  # end

  @impl :ra_machine
  def apply(_meta, {:write, key, value}, state) do
    {update_store(state, key, value), :ok, []}
  end

  def apply(_meta, {:read, key}, state) do
    {state, read_store(state, key), []}
  end

  # def apply(_meta, {:monitor, nodes}, state) do
  #   Logger.info("applying node monitors: #{inspect(nodes)}")
  #   {state, :ok, monitor_node(nodes)}
  # end

  # def apply(_meta, {:nodedown, node}, state) do
  #   Logger.info("#{node} down")
  #   {add_down_node(state, node), :ok, []}
  # end

  # def apply(_meta, {:nodeup, node}, state) do
  #   if down?(state, node) do
  #     Logger.info("#{node} up, restarting server on node")
  #     :ra.restart_server({:ra_kv, node})
  #     {clear_down_node(state, node), :ok, []}
  #   else
  #     Logger.info("#{node} was not emitted with :nodedown, skipping server restart")
  #     {state, :ok, []}
  #   end
  # end

  @impl :ra_machine
  def state_enter(raft_state, %__MODULE__{registry: _members}) do
    case raft_state do
      :leader ->
        Logger.info("leader state change, reissuing monitor effects")
        []

      # RaKvstore.Cluster.start_timer_interval(members)
      # monitor_node(members)

      change ->
        Logger.debug("state change: #{change}, no effects required")
        []
    end
  end

  # defp monitor_node(nodes) when is_list(nodes) do
  #   for n <- nodes, n != node() do
  #     monitor_node(n)
  #   end
  # end

  # defp monitor_node(node) do
  #   Logger.debug("leader monitoring #{node}")
  #   {:monitor, :node, node}
  # end
end
