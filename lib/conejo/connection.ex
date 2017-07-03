defmodule Conejo.Connection do
  @moduledoc """
  `Conejo.Connection` will be in control of the unique connection to RabbitMQ (AMQP Broker).
  """
  use GenServer
  use AMQP
  require Logger


  @reconnection_time 10_000  # millis
  @name :conejo_connection

  @doc """
  It starts (linked) a new `Conejo.Connection`
  """
  def start_link(_state, opts) do
    Logger.info("Conejo Connection begins ...")
    GenServer.start_link(__MODULE__, %{}, opts ++ [name: @name])
  end

  @doc false
  def init(_initial_state) do
    {:ok, rabbitmq_connect()}
  end

  @doc """
  It creates a new channel
  """
  @spec new_channel() :: {:ok, AMQP.Channel} | {:error, String.t}
  def new_channel() do
    GenServer.call(@name, :new_channel)
  end

  defp create_url do
    host = Confex.get(:conejo, :host)
    port = Confex.get(:conejo, :port)
    user = Confex.get(:conejo, :username)
    password = Confex.get(:conejo, :password)
    "amqp://#{user}:#{password}@#{host}:#{port}"
  end

  defp rabbitmq_connect() do
    case  create_url() |> Connection.open() do
      {:ok, conn} ->
        # Get notifications when the connection goes down
        Process.link(Map.get(conn, :pid))
        Logger.info("Connected to RabbitMQ #{Confex.get(:conejo, :host)}")
        conn
      {:error, message} ->
        Logger.error("Error Message during Connection: #{inspect message}")
        # Reconnection loop
        Process.sleep(@reconnection_time)
        Logger.info("Reconnecting ...")
        rabbitmq_connect()
    end
  end

  def handle_call(:new_channel, _from, conn) do
    result = case AMQP.Channel.open(conn) do
      {:ok, channel} -> {:ok, channel}
      error -> {:error, error}
    end
    {:reply, result, conn}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end