defmodule ConejoTest do
  use ExUnit.Case, async: true
  require Logger
  doctest Conejo


  test "send sync message" do
    Logger.info("* Send sync message test #{inspect self()}")
    assert :ok == MyPublisher.sync_publish(:publisher, "amq.topic", "example", "send sync message"), "Send sync message failed."
  end


  test "send async message" do
    Logger.info("* Send async message test #{inspect self()}")
    assert :ok == MyPublisher.async_publish(:publisher, "amq.topic", "example", "send async message"), "Send async message failed."
  end


  test "receive message" do
    Logger.info("* Receive message test #{inspect self()}")
    Process.register(self(), :test_received_message)
    defmodule ConsumerReceiveMessageTest do
      use Conejo.Consumer

      def handle_consume(_channel, payload, params) do
        Logger.info("Received Payload  ->  #{inspect payload}. \n Params: #{inspect params}")
        send(:test_received_message, payload)
      end
    end

    options = Application.get_all_env(:conejo)[:consumer3]
    {:ok, _consumer} = ConsumerReceiveMessageTest.start_link(options,  [name: :consumer3])

    Process.sleep(1_000)

    options = Application.get_all_env(:conejo)[:publisher]
    message = "Hola"
    MyPublisher.async_publish(:publisher, Keyword.get(options, :exchange), Keyword.get(options, :routing_key3), message)

    Logger.info("Waiting for the async message ...")
    assert_receive(_message, 1_000)
  end


  test "send async message to vhost" do
    Application.put_env(:conejo, :vhost, "dev")
    assert :ok == MyPublisher.async_publish(:publisher, "amq.topic", "example", "send async message"), "Send async message failed."
  end


end
