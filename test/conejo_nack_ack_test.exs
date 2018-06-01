defmodule ConejoNackAckTest do
  use ExUnit.Case, async: true
  require Logger

  test "4 nacks and 1 ack" do
    Logger.info("* 4 nacks and 1 ack test #{inspect(self())}")
    Process.register(self(), :test_nack_ack)

    defmodule Consumer4nacks1ackTest do
      use Conejo.Consumer

      def handle_consume(_channel, payload, %{delivery_tag: delivery_tag} = params) do
        Logger.info("Received Payload  ->  #{inspect(payload)}. \n Params: #{inspect(params)}")

        if delivery_tag < 5 do
          Logger.info("test_nack_ack: delivery_tag: #{delivery_tag}")
          :nack
        else
          send(:test_nack_ack, payload)
          :ack
        end
      end
    end

    c_options = Application.get_all_env(:conejo)[:consumer4]
    {:ok, _consumer} = Consumer4nacks1ackTest.start_link(c_options, name: :consumer4)
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
