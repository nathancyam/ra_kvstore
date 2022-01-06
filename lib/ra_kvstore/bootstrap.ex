defmodule RaKvstore.Bootstrap do
  @moduledoc false

  use GenServer

  alias RaKvstore.Config

  require Logger

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Logger.info("starting :ra application")
    :ra.start()
    Logger.info("started :ra application")

    delay = Config.bootstrap_delay()
    Process.send_after(self(), :start, delay)
    Logger.info("starting monitor process, delay start by #{delay}")
    {:ok, %{}}
  end

  @impl true
  def handle_info(:start, state) do
    if Config.leader?() do
      Logger.info("current node is designated as leader, #{inspect(node())}")
      RaKvstore.Cluster.start_leader()
    else
      Logger.info("current node is designated as follower, #{inspect(node())}")
      start_follower(Config.leader_node())
    end

    {:noreply, state}
  end

  defp start_follower(leader) do
    if Enum.member?(Node.list(), leader) do
      RaKvstore.Cluster.start_follower()
    end
  end
end
