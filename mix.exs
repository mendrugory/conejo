defmodule Conejo.Mixfile do
  use Mix.Project

  def project do
    [app: :conejo,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Conejo, []}]
  end

  defp description do
    """
    Conejo is a library based on pma/amqp which will help you to define your AMQP/RabbitMQ publishers and consumers in an easier way.
    """
  end

  defp deps do
    [{:amqp_client, git: "https://github.com/mendrugory/amqp_client.git", branch: "erlang_otp_19", override: true},
    {:amqp, "~> 0.1.5"},
    {:confex, ">= 0.0.0"}]
  end

 defp package do
    [name: :conejo,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Gonzalo Jiménez"],
     licenses: ["MIT License"],
     links: %{"GitHub" => "https://github.com/mendrugory/conejo"}]
  end
end
