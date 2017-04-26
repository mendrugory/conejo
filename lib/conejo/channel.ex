defmodule Conejo.Channel do

  @moduledoc """
  `Conejo.Channel` is the behaviour which will help you to implement your own RabbitMQ Channels.

  This behaviour is a low level module. I recommend to use `Conejo.Consumer`or `Conejo.Publisher` for your applications.
  """

  @type data :: any
  @type channel :: AMQP.Channel
  @type tag :: any
  @type redelivered :: any
  @type payload :: any
  @type options :: any
  @type params :: %{}
  @type exchange :: String.t
  @type exchange_type :: String.t
  @type queue :: AMQP.Queue

  @doc """
  It declares a queue
  """
  @callback declare_queue(channel, queue, options) :: any
  @doc """
  It declares an exchange
  """
  @callback declare_exchange(channel, exchange, exchange_type) :: any
  @doc """
  It binds to a queue
  """
  @callback bind_queue(channel, queue, exchange, options) :: any
  @doc """
  The channel starts to consume data
  """
  @callback consume_data(channel, queue, boolean) :: {:ok, String.t}
  @doc """
  Callback called when a message is received
  """
  @callback do_consume(channel, payload, params) :: any
  @doc """
  It publishes data asynchronously
  """
  @callback async_publish(any, exchange, String.t, payload) :: any
  @doc """
  It publishes data synchronously
  """
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
        IO.inspect args
        rabbitmq_options = if args == nil or Enum.empty?(args), do: %{}, else: Enum.into(args, %{})
        {:ok, %{chan: nil, rabbitmq_options: rabbitmq_options}}
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

      def handle_info({:basic_deliver, payload, params}, chan) do
        Task.start(fn -> do_consume(chan, payload, params) end)
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