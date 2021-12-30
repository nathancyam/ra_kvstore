defmodule RaKvstore do
  @moduledoc """
  Documentation for `RaKvstore`.
  """

  @server_reference :ra_kv

  def write(key, value) do
    cmd = {:write, key, value}

    case :ra.process_command(@server_reference, cmd) do
      {:ok, term, _leader} ->
        {:ok, term}

      {:timeout, _err} ->
        :timeout

      unknown ->
        unknown
    end
  end

  def read(key) do
    case :ra.consistent_query(@server_reference, &Map.get(&1, key)) do
      {:ok, val, _leader} ->
        {:ok, val}

      {:timeout, _} ->
        :timeout

      {:error, _} = err ->
        err
    end
  end
end
