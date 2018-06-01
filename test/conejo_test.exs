defmodule ConejoTest do
  use ExUnit.Case, async: true
  require Logger

  test "send sync message" do
    Logger.info("* Send sync message test #{inspect(self())}")

    assert :ok ==
             MyPublisher.sync_publish(:publisher, "amq.topic", "example", "send sync message"),
           "Send sync message failed."
  end

  test "send async message" do
    Logger.info("* Send async message test #{inspect(self())}")

    assert :ok ==
             MyPublisher.async_publish(:publisher, "amq.topic", "example", "send async message"),
           "Send async message failed."
  end

  test "receive message" do
    Logger.info("* Receive message test #{inspect(self())}")
    Process.register(self(), :test_received_message)

    p_options3 = Application.get_all_env(:conejo)[:publisher3]
    message = "Hola"

    Process.sleep(1_000)

    MyPublisher.async_publish(
      :publisher,
      Keyword.get(p_options3, :exchange),
      Keyword.get(p_options3, :routing_key),
      message
    )

    Logger.info("Waiting for the async message ...")
    assert_receive(_message, 1_000)
  end

  test "send async message to vhost" do
    Application.put_env(:conejo, :vhost, "dev")

    assert :ok ==
             MyPublisher.async_publish(:publisher, "amq.topic", "example", "send async message"),
           "Send async message failed."
  end
end
