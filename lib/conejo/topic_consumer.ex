defmodule Conejo.TopicConsumer do


  @moduledoc """
  Conejo.TopicChannel is the behaviour which will help you to implement your own RabbitMQ Topic Consumers.
  Implements your consume function that will be use as a callback when a message arrives.
  """

  @type options :: []
  @type data :: any
  @type channel :: AMQP.Channel
  @type tag :: any
  @type redelivered :: any
  @type payload :: any

  @callback consume(channel, tag, redelivered, payload) :: any

  defmacro __using__(_) do
    quote location: :keep do
      use Conejo.Channel
      @behaviour Conejo.TopicConsumer

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

      def do_consume(channel, tag, redelivered, payload) do
        consume(channel, tag, redelivered, payload)
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