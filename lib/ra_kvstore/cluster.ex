defmodule RaKvstore.Cluster do
  @moduledoc false

  alias RaKvstore.Config

  require Logger

  @cluster_name "ra_kv"

  def start_leader(nodes \\ []) do
    machine = {:module, RaKvstore.State, %{nodes: nodes}}
    :ra.start_cluster(:default, @cluster_name, machine, [{:ra_kv, node()}])
  end

  def start_follower do
    machine = {:module, RaKvstore.State, %{nodes: []}}
    leader = leader_definition()
    follower = {:ra_kv, node()}

    Logger.info("starting and adding follower: #{inspect(follower)}, leader: #{inspect(leader)}")

    case add_member(leader, follower) do
      :ok ->
        Logger.info("starting follower server")
        :ra.start_server(:default, @cluster_name, follower, machine, [leader])

      {:error, :already_member} ->
        Logger.info("restarting follower server")
        :ra.restart_server(follower)
    end
  end

  defp add_member(leader, follower) do
    case :ra.add_member(leader, follower) do
      {:ok, _, _} ->
        Logger.info("added follower as cluster member")
        :ok

      {:error, :already_member} = err ->
        Logger.warn("follower is already an member")
        err
    end
  end

  @spec leader_definition() :: {atom(), atom()}
  defp leader_definition do
    case :ra.members(:ra_kv) do
      {:ok, _members, leader} ->
        Logger.info("found :ra leader via members/1")
        leader

      {:timeout, _} ->
        Logger.warn(":ra timeout, using configured leader node")
        {:ra_kv, Config.leader_node()}

      {:error, _} ->
        Logger.warn(":ra error, using configured leader node")
        {:ra_kv, Config.leader_node()}
    end
  end

  # def connect_nodes(nodes) do
  #   Enum.each(nodes, fn node ->
  #     Node.connect(node)
  #   end)
  # end

  # def start_timer_interval(nodes) do
  #   :timer.apply_interval(:timer.seconds(5), __MODULE__, :connect_nodes, [nodes])
  # end
end
