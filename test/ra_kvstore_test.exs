defmodule RaKvstoreTest do
  use ExUnit.Case
  doctest RaKvstore

  test "greets the world" do
    assert RaKvstore.hello() == :world
  end
end
