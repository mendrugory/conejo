defmodule ConejoTest do
  use ExUnit.Case
  doctest Conejo

  test "connect consumer" do
    options = Application.get_all_env(:conejo)[:consumer]
    result = MyConsumer.start_link(options, [name: :consumer])
    assert elem(result, 0) == :ok, "Connection consumer test failed"
  end

  test "connect publisher" do
    options = Application.get_all_env(:conejo)[:publisher]
    result = MyConsumer.start_link(options, [name: :publisher])
    assert elem(result, 0) == :ok, "Connection published test failed"
  end


end
