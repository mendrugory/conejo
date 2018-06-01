defmodule Conejo do
  use Application

  @moduledoc """
  `Conejo` is an OTP application/library which will help you to define and keep up your AMQP/RabbitMQ consumers and publishers (or producers).

  This application is based on (pma/amqp)[https://github.com/pma/amqp] library.

  Before your app is started, Conejo will connect to the chosen broker establishing a supervised connection. In order to get it, Conejo
  needs the following configuration in the config files:

  ```elixir
  config :conejo,
    host: "my_host",
    port: 5672,
    vhost: "dev",
    username: "user",
    password: "pass"
  ```

  If you whish to use a virtual host, you can specify an optional parameter called "vhost" containing your wanted vhost (eg. "dev").

  check `Conejo.Consumer` in order to know the its configuration.

  `Conejo.Publisher` does not need any configuration.
  """

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Conejo.Connection, [[], []])
    ]

    opts = [strategy: :one_for_one, name: Conejo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
