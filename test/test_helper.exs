require Logger

cmds =
  [
    {"docker", ["kill", "rabbitmq"]},
    {"docker", ["rm", "rabbitmq"]},
    {"docker", ["run", "-d", "-p", "15672:15672", "-p", "5672:5672", "--name", "rabbitmq", "rabbitmq:3-management"]}
  ]

#Enum.each(cmds, fn {cmd, args} -> System.cmd(cmd, args) end)

Logger.info "Waiting for RabbitMQ Broker (Docker Container) ..."
#Process.sleep(10000)

Application.ensure_all_started(:conejo)
Logger.info "Conejo Tests begin ..."
Process.sleep(100)

defmodule MyPublisher do
  use Conejo.Publisher
end

ExUnit.start()