defmodule RaKvstore.Config do
  @moduledoc false

  @spec leader?() :: boolean()
  def leader? do
    node() == leader_node()
  end

  @spec bootstrap_delay() :: non_neg_integer()
  def bootstrap_delay do
    Application.get_env(:ra_kvstore, :bootstrap_delay)
  end

  @spec leader_node() :: atom()
  def leader_node do
    Application.get_env(:ra_kvstore, :leader)
  end
end
