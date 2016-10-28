defmodule Conejo.Channel do
  use GenServer
  use AMQP
  require Logger
  import Conejo.Connection

  @moduledoc """
  Conejo.Channel is the behaviour which will help you to implement your own RabbitMQ Channels.
  """

  @type options :: []
  @type data :: any
  @type channel :: AMQP.Channel
  @type tag :: any
  @type redelivered :: any
  @type payload :: any

  @time_sleep 4_000  # wait time for conejo connection



    @doc """
    Starts a `Channel` process linking to the parent process.
    See `start_link/3` for more information.
    """
    @spec start_link(module, any, options) :: GenServer.on_start
    def start_link(module, args, options \\ []) when is_atom(module) and is_list(options) do
      GenServer.start_link(__MODULE__, {module, args}, options)
    end

    @doc """
    Starts a `Channel` process without links (outside of a supervision tree).
    See `start_link/3` for more information.
    """
    @spec start(module, any, options) :: GenServer.on_start
    def start(module, args, options \\ []) when is_atom(module) and is_list(options) do
      GenServer.start(__MODULE__, {module, args}, options)
    end

    @doc """
    It only connects the channel
    """
    def init(args) do
      connect_channel(args)
    end



  @callback consume(channel, tag, redelivered, payload) :: any
  @callback handle_data_and_publish(channel, data) :: any


  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Channel

      def handle_call({:publish, data}, _from, state) do
        handle_data_and_publish(state[:channel], data)
        {:reply, :ok, state}
      end

      def handle_call(msg, _from, state) do
        # We do this to trick Dialyzer to not complain about non-local returns.
        reason = {:bad_call, msg}
        case :erlang.phash2(1, 1) do
          0 -> exit(reason)
          1 -> {:stop, reason, state}
        end
      end

      def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, state) do
        Task.start(fn -> consume(state[:channel], tag, redelivered, payload) end)
        {:noreply, state}
      end

      def handle_info(_msg, state) do
        {:noreply, [], state}
      end

      def handle_cast({:publish, data}, state) do
        Task.start(fn -> handle_data_and_publish(state[:channel], data) end)
        {:noreply, state}
      end

      def handle_cast(msg, state) do
        # We do this to trick Dialyzer to not complain about non-local returns.
        reason = {:bad_cast, msg}
        case :erlang.phash2(1, 1) do
          0 -> exit(reason)
          1 -> {:stop, reason, state}
        end
      end

      def terminate(_reason, _state) do
        :ok
      end

      def code_change(_old, state, _extra) do
        {:ok, state}
      end

      defoverridable [handle_call: 3, handle_info: 2, handle_cast: 2, terminate: 2, code_change: 3]
    end
  end





  @doc"""
        It connects the channel using the given opts.
        args is a Conejo.ChannelArguments record
        """
        defp connect_channel(args) do
          # Waiting for the Conejo.Connection
          Process.sleep(@time_sleep)
          # Monitoring the connection
          Conejo.Connection.monitor()
          {:ok, conn} = Conejo.Connection.get_connection()
          {:ok, chan} = Channel.open(conn)
          Process.link(Map.get(chan, :pid))
          if Map.get(args, :consumer?) do
            queue = args |> Map.get(:queue_arguments) |> Map.get(:name)
            Queue.declare(chan, queue, args |> Map.get(:queue_arguments) |> Map.get(:args))
            Queue.bind(chan, queue, Map.get(args, :exchange), [routing_key: Map.get(args, :routing_key)])
            {:ok, _consumer_tag} = Basic.consume(chan, queue, nil, no_ack: Map.get(args, :no_ack))
          else
            AMQP.Exchange.declare(chan, Map.get(args, :exchange), Map.get(args, :exchange_type))
          end
          {:ok, %{channel: chan, arguments: args}}
        end


      @doc """
      It publishes
      """
      def publish(publisher, :no_wait, data) do
        GenServer.cast(publisher, {:publish, data})
      end

      @doc """
      It publishes
      """
      def publish(publisher, :wait, data) do
        GenServer.call(publisher, {:publish, data})
      end

      # Confirmation sent by the broker after registering this process as a consumer
      def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, state) do
        {:noreply, state}
      end

      # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
      def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, state) do
        {:stop, :normal, state}
      end

      # Confirmation sent by the broker to the consumer process after a Basic.cancel
      def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, state) do
        {:noreply, state}
      end

      def handle_info({:DOWN, _, :process, _pid, reason}, state) do
        AMQP.Channel.close(state[:channel])
        # Waiting for the Conejo.Connection
        Process.sleep(@time_sleep)
        # new channel using the new connection
        {:ok, new_state} = connect_channel(state[:arguments])
        Logger.info("Restarted channel #{inspect self()}")
        {:noreply, new_state}
      end


end

