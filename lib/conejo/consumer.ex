defmodule Conejo.Consumer do


  @moduledoc """
  Conejo.Consumer is the behaviour which will help you to implement your own RabbitMQ Topic Consumers.
  Implements your consume function that will be use as a callback when a message arrives.
  """

  @type options :: []
  @type data :: any
  @type channel :: AMQP.Channel
  @type tag :: any
  @type redelivered :: any
  @type payload :: any
  @type params :: any

  @callback consume(channel, payload, params) :: any

  defmacro __using__(_) do
    quote location: :keep do
      use Conejo.Channel
      @behaviour Conejo.Consumer

      def declare_queue(chan, queue, options) do
        AMQP.Queue.declare(chan, queue, options)
      end

      def declare_exchange(chan, exchange, exchange_type) do
        nil
      end

      def bind_queue(chan, queue, exchange, options) do
        AMQP.Queue.bind(chan, queue, exchange, options)
      end

      def consume_data(chan, queue, options) do
        AMQP.Basic.consume(chan, queue, nil, options)
      end

      def do_consume(channel, payload, params) do
        consume(channel, payload, params)
      end

      def async_publish(publisher, exchange, topic, message) do
        nil
      end

      def sync_publish(publisher, exchange, topic, message) do
        nil
      end

    end
  end
end