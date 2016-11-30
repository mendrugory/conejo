defmodule Conejo.Publisher do

  @moduledoc """
  Conejo.Publisher is the behaviour which will help you to implement your own RabbitMQ Publisher.
  Implements your consume function that will be use as a callback when a message arrives.
  """


  defmacro __using__(_) do
    quote location: :keep do
      use Conejo.Channel
      @behaviour Conejo.Publisher

      def declare_queue(chan, queue, options) do
        nil
      end

      def declare_exchange(chan, exchange, exchange_type) do
        nil #AMQP.Exchange.declare(chan, exchange, exchange_type)
      end

      def bind_queue(chan, queue, exchange, options) do
        nil
      end

      def consume_data(chan, queue, no_ack) do
        {:ok, nil}
      end

      def do_consume(channel, tag, redelivered, payload) do
        nil
      end

      def async_publish(publisher, exchange, topic, message) do
        GenServer.cast(publisher, {:publish, exchange, topic, message})
      end

      def sync_publish(publisher, exchange, topic, message) do
        GenServer.call(publisher, {:publish, exchange, topic, message})
      end

    end
  end
end