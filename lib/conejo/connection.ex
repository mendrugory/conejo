defmodule Conejo.Connection do
  use GenServer
  use AMQP
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
    conn = rabbitmq_connect()
    {:ok, conn}
  end

  @doc """
  It returns the pid of the rabbitmq connection
  """
  def get_connection() do
    GenServer.call(@name, :get_connection)
  end

  defp create_url do
    host = Application.get_env(:conejo, :host)
    port = Application.get_env(:conejo, :port)
    user = Application.get_env(:conejo, :username)
    password = Application.get_env(:conejo, :password)
    "amqp://#{user}:#{password}@#{host}:#{port}"
  end

  defp rabbitmq_connect do
    case  create_url() |> Connection.open() do
    {:ok, conn} ->
      # Get notifications when the connection goes down
      Process.link(Map.get(conn, :pid))
      Logger.info("Connected to RabbitMQ #{Application.get_env(:conejo, :host)}")
      {:ok, conn}
    {:error, message} ->
      Logger.error("Error Message during Connection: #{ inspect message}")
      # Reconnection loop
      :timer.sleep(@reconnection_time)
      Logger.info("Reconnecting ...")
      rabbitmq_connect
    end
  end

  def handle_call(:get_connection, _from, state) do
    {:reply, state, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

end