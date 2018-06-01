defmodule Conejo.Publisher do
  @moduledoc """
  `Conejo.Publisher` is the behaviour which will help you to implement your own RabbitMQ Publisher.

  ### Definition
  ```elixir
  defmodule MyApplication.MyPublisher do
    use Conejo.Publisher
  end
  ```
  ### Start Up
  ```elixir
  {:ok, publisher} = MyApplication.MyPublisher.start_link([], [name: :publisher])
  ```

  ### Synchronous Publishing
  ```elixir
  MyApplication.MyPublisher.sync_publish(:publisher, "my_exchange", "example", "Hola")
  ```

  ### Asynchronous Publishing
  ```elixir
  MyApplication.MyPublisher.async_publish(:publisher, "my_exchange", "example", "Adios")
  ```
  """

  defmacro __using__(_) do
    quote location: :keep do
      use Conejo.Channel
      @behaviour Conejo.Publisher

      def declare_queue(_chan, _queue, _options) do
        nil
      end

      def declare_exchange(_chan, _exchange, _exchange_type) do
        # AMQP.Exchange.declare(chan, exchange, exchange_type)
        nil
      end

      def bind_queue(_chan, _queue, _exchange, _options) do
        nil
      end

      def consume_data(_chan, _queue, _no_ack) do
        {:ok, nil}
      end

      def do_consume(_channel, _payload, _params) do
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
