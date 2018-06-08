defmodule ConejoNackNoRequeueTest do
  use ExUnit.Case, async: true
  require Logger

  test "test nack no requeue" do
    Logger.info("* nack no requeue test #{inspect(self())}")
    Process.register(self(), :test_nack_no_requeue)

    p_options = Application.get_all_env(:conejo)[:publisher6]
    message = "Hola"
    Process.sleep(1_000)

    MyPublisher.async_publish(
      :publisher,
      Keyword.get(p_options, :exchange),
      Keyword.get(p_options, :routing_key),
      message
    )

    Logger.info("Waiting for the async message ...")
    assert_receive(_message, 1_000)
  end
end
