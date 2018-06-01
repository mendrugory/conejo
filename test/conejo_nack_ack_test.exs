defmodule ConejoNackAckTest do
  use ExUnit.Case, async: true
  require Logger

  test "4 nacks and 1 ack" do
    Logger.info("* 4 nacks and 1 ack test #{inspect(self())}")
    Process.register(self(), :test_nack_ack)

    p_options = Application.get_all_env(:conejo)[:publisher4]
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
