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

Logger.info("Number of Schedulers: #{System.schedulers_online()}")

{:ok, _publisher} = MyPublisher.start_link([], name: :publisher)

c_options3 = Application.get_all_env(:conejo)[:consumer3]
{:ok, _consumer} = ConsumerReceiveMessageTest.start_link(c_options3, name: :consumer3)

c_options = Application.get_all_env(:conejo)[:consumer5]
{:ok, _consumer} = ConsumerRejectTest.start_link(c_options, name: :consumer5)

c_options = Application.get_all_env(:conejo)[:consumer6]
{:ok, _consumer} = ConsumerNackNoRequeue.start_link(c_options, name: :consumer6)

c_options = Application.get_all_env(:conejo)[:consumer4]
{:ok, _consumer} = Consumer4nacks1ackTest.start_link(c_options, name: :consumer4)

Process.sleep(1_000)

ExUnit.start()
