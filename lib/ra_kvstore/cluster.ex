defmodule RaKvstore.Cluster do
  @moduledoc false

  require Logger

  @cluster_name "ra_kv"
  @machine {:module, RaKvstore.State, %{}}

  def start do
    nodes =
      for node_str <- Application.get_env(:ra_kvstore, :nodes, []) do
        String.to_atom(node_str)
      end

    Logger.info("starting or joining raft cluster with #{inspect(nodes)}")
    start_leader(nodes)
  end

  def start_leader(nodes) do
    [leader | _followers] = Enum.sort(nodes)
    Logger.info("Expected leader node: #{leader}")

    if leader == node() do
      Logger.info("configuring leader node: #{leader}")
      :ok = wait_for_nodes(nodes)
      :timer.sleep(2_000)

      ra_nodes =
        for n <- nodes do
          {:ra_kv, n}
        end

      {:ok, server_started, _server_failed} =
        log_start_cluster(:ra.start_cluster(:default, @cluster_name, @machine, ra_nodes))

      {:ok, hd(server_started)}
    else
      Logger.info("Follower node: #{node()}")
      :ok
    end
  end

  def log_start_cluster({:ok, servers_started, servers_failed}) do
    Logger.info("servers started: #{inspect(servers_started)}")

    unless Enum.empty?(servers_failed) do
      Logger.warn("servers failed to start: #{inspect(servers_failed)}")
      {:error, :incomplete_cluster}
    else
      {:ok, servers_started, servers_failed}
    end
  end

  def wait_for_nodes(done) when done == [] do
    Logger.info("all nodes have been connected")
    :ok
  end

  def wait_for_nodes([node | rem] = all_nodes) do
    case Node.connect(node) do
      true ->
        Logger.info("Connected to node: #{node}, connecting to next node...")
        wait_for_nodes(rem)

      false ->
        Logger.error("Could not connect to node: #{node}, Sleeping...")
        :timer.sleep(1_000)
        wait_for_nodes(all_nodes)
    end
  end
end
