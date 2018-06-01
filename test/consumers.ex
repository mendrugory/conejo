defmodule ConsumerReceiveMessageTest do
  use Conejo.Consumer

  def handle_consume(_channel, payload, params) do
    Logger.info("Received Payload  ->  #{inspect(payload)}. \n Params: #{inspect(params)}")
    send(:test_received_message, payload)
  end
end

defmodule ConsumerRejectTest do
  use Conejo.Consumer

  def handle_consume(_channel, payload, params) do
    Logger.info("Received Payload  ->  #{inspect(payload)}. \n Params: #{inspect(params)}")
    send(:test_reject, payload)
    :reject
  end
end

defmodule ConsumerNackNoRequeue do
  use Conejo.Consumer

  def handle_consume(_channel, payload, params) do
    Logger.info("Received Payload  ->  #{inspect(payload)}. \n Params: #{inspect(params)}")
    send(:test_nack_no_requeue, payload)
    {:nack, requeue: false}
  end
end

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
