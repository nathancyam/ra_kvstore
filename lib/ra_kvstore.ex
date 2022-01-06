defmodule RaKvstore do
  @moduledoc """
  Documentation for `RaKvstore`.
  """

  @server_reference :ra_kv

  alias RaKvstore.State

  def put(key, value) do
    cmd = {:write, key, value}

    case :ra.process_command(@server_reference, cmd) do
      {:ok, _term, leader} ->
        {:ok, leader}

      {:timeout, _err} ->
        :timeout

      unknown ->
        unknown
    end
  end

  def get(key) do
    case :ra.consistent_query(@server_reference, &State.read_store(&1, key)) do
      {:ok, val, leader} ->
        {:ok, val, leader}

      {:timeout, _} ->
        :timeout

      {:error, _} = err ->
        err
    end
  end
end
