defmodule ConejoRejectTest do
  use ExUnit.Case, async: true
  require Logger

  test "test reject" do
    Logger.info("* Reject test #{inspect(self())}")
    Process.register(self(), :test_reject)

    defmodule ConsumerRejectTest do
      use Conejo.Consumer

      def handle_consume(_channel, payload, params) do
        Logger.info("Received Payload  ->  #{inspect(payload)}. \n Params: #{inspect(params)}")
        send(:test_reject, payload)
        :reject
      end
    end

    c_options = Application.get_all_env(:conejo)[:consumer5]
    {:ok, _consumer} = ConsumerRejectTest.start_link(c_options, name: :consumer5)
    p_options = Application.get_all_env(:conejo)[:publisher5]
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
