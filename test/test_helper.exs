require Logger

unless System.get_env("TRAVISCICONEJO") do
  cmds = [
    {"docker", ["kill", "rabbitmq"]},
    {"docker", ["rm", "rabbitmq"]},
    {"docker",
     [
       "run",
       "-d",
       "-p",
       "15672:15672",
       "-p",
       "5672:5672",
       "--name",
       "rabbitmq",
       "rabbitmq:3-management"
     ]}
  ]

  Enum.each(cmds, fn {cmd, args} -> System.cmd(cmd, args) end)

  Logger.info("Waiting for RabbitMQ Broker (Docker Container) ...")
  Process.sleep(9_000)
end

setup_cmds = [
  {"docker",
   [
     "exec",
     "rabbitmq",
     "su",
     "rabbitmq",
     "--",
     "/usr/lib/rabbitmq/bin/rabbitmqctl",
     "add_vhost",
     "dev"
   ]},
  {"docker",
   [
     "exec",
     "rabbitmq",
     "su",
     "rabbitmq",
     "--",
     "/usr/lib/rabbitmq/bin/rabbitmqctl",
     "set_permissions",
     "-p",
     "dev",
     "guest",
     ".*",
     ".*",
     ".*"
   ]}
]

Logger.info("Setting up RabbitMQ Broker (Docker Container) ...")
Enum.each(setup_cmds, fn {cmd, args} -> System.cmd(cmd, args) end)
Process.sleep(1_000)

Application.ensure_all_started(:conejo)
Logger.info("Conejo Tests begin ...")
Process.sleep(100)

defmodule MyPublisher do
  use Conejo.Publisher
end

Logger.info("Number of Schedulers: #{System.schedulers_online}")

{:ok, _publisher} = MyPublisher.start_link([], name: :publisher)
Process.sleep(1_000)

ExUnit.start()
