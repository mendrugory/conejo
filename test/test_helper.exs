require Logger
Application.stop(:conejo)

cmds =
  [
    {"docker", ["kill", "rabbitmq"]},
    {"docker", ["rm", "rabbitmq"]},
    {"docker", ["run", "-d", "-p", "15672:15672", "-p", "5672:5672", "--name", "rabbitmq", "rabbitmq:3-management"]}
  ]

Enum.each(cmds, fn {cmd, args} -> System.cmd(cmd, args) end)

Logger.info "Waiting for RabbitMQ ..."
Process.sleep(10000)

Logger.info "Conejo Tests begin ..."
Application.start(:conejo)
Process.sleep(4000)

defmodule MyConsumer do
  use Conejo.Consumer

  def consume(_channel, _tag, _redelivered, payload) do
    IO.puts "Received  ->  #{inspect payload}"
    send(:test_process, payload)
  end
end

defmodule MyPublisher do
  use Conejo.Publisher
end

ExUnit.start()