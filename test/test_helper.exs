require Logger

unless System.get_env "TRAVISCICONEJO" do
  cmds =
    [
      {"docker", ["kill", "rabbitmq"]},
      {"docker", ["rm", "rabbitmq"]},
      {"docker", ["run", "-d", "-p", "15672:15672", "-p", "5672:5672", "--name", "rabbitmq", "rabbitmq:3-management"]}
    ]

  Enum.each(cmds, fn {cmd, args} -> System.cmd(cmd, args) end)

  Logger.info "Waiting for RabbitMQ Broker (Docker Container) ..."
  Process.sleep(5_000)
end

Application.ensure_all_started(:conejo)
Logger.info "Conejo Tests begin ..."
Process.sleep(100)

defmodule MyPublisher do
  use Conejo.Publisher
end

{:ok, _publisher} = MyPublisher.start_link([], [name: :publisher])
Process.sleep(1_000)

ExUnit.start()