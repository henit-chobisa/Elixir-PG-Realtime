defmodule PostgresListenerTest do
  use ExUnit.Case
  doctest PostgresListener

  test "greets the world" do
    assert PostgresListener.hello() == :world
  end
end
