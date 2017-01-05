defmodule Conejo.Connection do
  use GenServer
  use AMQP
  use Confex
  require Logger
  @moduledoc """
  Conejo.Connection will be the module which will be in control of the unique connection to RabbitMQ
  """

  @reconnection_time 10_000  # millis
  @name :conejo_connection

  def start_link(_state, opts) do
    Logger.info("Conejo Connection begins ...")
    GenServer.start_link(__MODULE__, %{}, opts ++ [name: @name])
  end

  def init(_initial_state) do
    {:ok, rabbitmq_connect()}
  end

  @doc """
  It returns the pid of the rabbitmq connection
  """
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
        Logger.error("Error Message during Connection: #{ inspect message}")
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

  def handle_info(msg, state) do
    {:noreply, state}
  end

end


"""

defmodule MyApplication.MyConsumer do
  use Conejo.Consumer

  def consume(_channel, _tag, _redelivered, payload) do
    IO.inspect payload
  end
end
options = Application.get_all_env(:conejo)[:consumer]
{:ok, consumer1} = MyApplication.MyConsumer.start_link(options, [name: :consumer1])

defmodule MyApplication.MyPublisher do
  use Conejo.Publisher

end

{:ok, publisher} = MyApplication.MyPublisher.start_link([], [name: :publisher])

MyApplication.MyPublisher.sync_publish(:publisher, "amq.topic", "example", "Hola")
"""