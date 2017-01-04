defmodule ConejoTest do
  use ExUnit.Case, async: true
  require Logger
  doctest Conejo


  test "send sync message" do
    Logger.info("* send sync message test #{inspect self()}")
    Process.sleep(1_000)
    options = Application.get_all_env(:conejo)[:publisher]
    {:ok, publisher} = MyPublisher.start_link(options, [name: PublisherSyncMessageTest])
    Process.sleep(4_000)
    assert :ok == MyPublisher.sync_publish(publisher, "amq.topic", "example", "send sync message"), "Send sync message failed."
  end


  test "send async message" do
    Logger.info("* send async message test #{inspect self()}")
    options = Application.get_all_env(:conejo)[:publisher]
    {:ok, publisher} = MyPublisher.start_link(options, [name: PublisherAsyncMessageTest])
    Process.sleep(4_000)
    assert :ok == MyPublisher.async_publish(publisher, "amq.topic", "example", "send async message"), "Send async message failed."
  end


  test "receive message" do
    Logger.info("* receive message test #{inspect self()}")
    Process.register self, :test_received_message
    defmodule ConsumerReceiveMessageTest do
      use Conejo.Consumer

      def consume(_channel, _tag, _redelivered, payload) do
        Logger.info("Received  ->  #{inspect payload}")
        send(:test_received_message, payload)
      end
    end

    options = Application.get_all_env(:conejo)[:receive_async_consumer]
    {:ok, consumer} = ConsumerReceiveMessageTest.start_link(options, [name: ConsumerReceiveMessageTest])

    options = Application.get_all_env(:conejo)[:publisher]
    {:ok, publisher} = MyPublisher.start_link(options, [name: PublisherConsumerReceiveAsyncMessageTest])

    Process.sleep(4_000)

    assert :ok == MyPublisher.async_publish(publisher, "amq.topic", "example", "Hola")

    Logger.info("Waiting for the async message")
    assert_receive("Hola", 1_000)
  end


end
