defmodule Conejo.Channel do

  @moduledoc """
  Conejo.Channel is the behaviour which will help you to implement your own RabbitMQ Channels.
  """

  @type data :: any
  @type channel :: AMQP.Channel
  @type tag :: any
  @type redelivered :: any
  @type payload :: any
  @type options :: any
  @type exchange :: String.t
  @type exchange_type :: String.t
  @type queue :: AMQP.Queue

  @callback declare_queue(channel, queue, options) :: any
  @callback declare_exchange(channel, exchange, exchange_type) :: any
  @callback bind_queue(channel, queue, exchange, options) :: any
  @callback consume_data(channel, queue, boolean) :: {:ok, String.t}
  @callback do_consume(channel, String.t, boolean, any) :: any
  @callback async_publish(any, exchange, String.t, payload) :: any
  @callback sync_publish(any, exchange, String.t, payload) :: any



  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Conejo.Channel
      use GenServer
      use AMQP
      require Logger
      require Conejo.Connection

      @time_sleep 200  # wait time for conejo connection

      def start_link(state, opts) do
        GenServer.start_link(__MODULE__, state, opts)
      end

      def init(args) do
        Logger.info("Waiting #{@time_sleep} ms in order to be sure that the Connection to RabbitMQ is done.")
        Process.send_after(self(), :connect, @time_sleep)
        {:ok, %{chan: nil, rabbitmq_options: Enum.into(args, %{})}}
      end

      def handle_cast({:publish, exchange, topic, message}, chan) do
        Task.start(fn -> AMQP.Basic.publish(chan, exchange, topic, message) end)
        {:noreply, chan}
      end

      def handle_call({:publish, exchange, topic, message}, _from, chan) do
        AMQP.Basic.publish(chan, exchange, topic, message)
        {:reply, :ok, chan}
      end

      def handle_info(:connect, state) do
        channel = connect_channel(state[:rabbitmq_options])
        {:noreply, channel}
      end

      # Confirmation sent by the broker after registering this process as a consumer
      def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
        {:noreply, chan}
      end

      # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
      def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
        {:stop, :normal, chan}
      end

      # Confirmation sent by the broker to the consumer process after a Basic.cancel
      def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
        {:noreply, chan}
      end

      def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
        Task.start(fn -> do_consume(chan, tag, redelivered, payload) end)
        {:noreply, chan}
      end

      def handle_info({:EXIT, pid, :shutdown}, _state) do
        Logger.info("Conejo Connection has died (:EXIT), therefore I have to die as well.")
        Process.exit(self(), :kill)
      end

      def handle_info({:DOWN, _, :process, _pid, reason}, state) do
        Logger.info("Conejo Connection has died (:DOWN), therefore I have to die as well. Reason: #{inspect reason}")
        Process.exit(self(), :kill)
      end

      def handle_info(msg, state) do
        {:noreply, state}
      end

      defp connect_channel(options) do
        try do
          case Conejo.Connection.new_channel() do
            {:ok, chan} ->
               Process.monitor(:conejo_connection)
               Process.link(Map.get(chan, :pid))
               queue = options[:queue_name]
               declare_exchange(chan, Map.get(options, :exchange, "exchange"), Map.get(options, :exchange_type, "topic"))
               declare_queue(chan, queue, Map.get(options, :queue_declaration_options, []))
               bind_queue(chan, queue, Map.get(options, :exchange, "exchange"), Map.get(options, :queue_bind_options, []))
               {:ok, _consumer_tag} = consume_data(chan, queue, Map.get(options, :consume_options, []))
               Logger.info("Channel connected #{inspect self()}")
               chan
            {:error, error} ->
              Logger.error("Error Opening the channel. #{inspect error}")
              Process.sleep(@time_sleep)
              connect_channel(options)
          end
        rescue
          e ->
            Logger.error("No channel connection. #{inspect e}")
            Process.sleep(@time_sleep)
            connect_channel(options)
        end
      end

    end
  end
end