defmodule RaKvstore.State do
  @moduledoc false

  @behaviour :ra_machine

  @impl :ra_machine
  def init(_config) do
    %{}
  end

  @impl :ra_machine
  def apply(_meta, {:write, key, value}, state) do
    {Map.put(state, key, value), :ok, []}
  end

  def apply(_meta, {:read, key}, state) do
    {state, Map.get(state, key), []}
  end
end
