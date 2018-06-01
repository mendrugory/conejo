defmodule Conejo.Consumer do
  @moduledoc """
  `Conejo.Consumer` is the behaviour which will help you to implement your own RabbitMQ consumers.

  ### Configuration
  Conejo.Consumer needs a configuration in the environment files.

  Example:
  ```elixir
  config :my_application, :consumer,
    exchange: "my_exchange",
    exchange_type: "topic",
    queue_name: "my_queue",
    queue_declaration_options: [{:auto_delete, true}, {:exclusive, true}],
    queue_bind_options: [routing_key: "example"],
    consume_options: [no_ack: true]
  ```

  ### Definition
  ```elixir
  defmodule MyConsumer do
    use Conejo.Consumer

    def handle_consume(_channel, payload, _params) do
      IO.inspect payload
    end
  end
  ```

  ### Start Up
  ```elixir
    options = Application.get_all_env(:my_application)[:consumer]
    {:ok, consumer} = MyConsumer.start_link(options, [name: :consumer])
  ```

  """

  @type channel :: AMQP.Channel
  @type payload :: any
  @type params :: %{}
  @type ack_opts :: [multiple: boolean]
  @type nack_opts :: [multiple: boolean, requeue: boolean]
  @type reject_opts :: [requeue: boolean]

  @doc """
  It will be executed after a message is received in an independant process.

  * **payload**: The received message.
  * **params**: All the available parameters related to the received message.

  It has to return: 
  * If there is acknowledge:
    * `:ack` 
    * `{:ack, ack_opts}` 
    * `:nack`
    * `{:nack, nack_opts}`
    * `:reject` 
    * `{:reject, reject_opts}` 
    where the options are Keyword lists like : _[multiple: boolean, requeue: boolean]_
  * If there is no acknowledge: 
    * Any other value
  """
  @callback handle_consume(channel, payload, params) ::
              :ack
              | {:ack, ack_opts}
              | :nack
              | {:nack, nack_opts}
              | :reject
              | {:reject, reject_opts}
              | any

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
        a = AMQP.Basic.consume(chan, queue, nil, options)
      end

      def do_consume(channel, payload, params) do
        case handle_consume(channel, payload, params) do
          :ack ->
            AMQP.Basic.ack(channel, params.delivery_tag)

          {:ack, ack_opts} ->
            AMQP.Basic.ack(channel, params.delivery_tag, ack_opts)

          :nack ->
            AMQP.Basic.nack(channel, params.delivery_tag)

          {:nack, nack_opts} ->
            AMQP.Basic.nack(channel, params.delivery_tag, nack_opts)

          _ ->
            :ok
        end
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
