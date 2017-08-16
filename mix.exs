defmodule Conejo.Mixfile do
  use Mix.Project

  @version "0.3.3"

  def project do
    [app: :conejo,
     version: @version,
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     docs: [main: "Conejo", source_ref: "v#{@version}",
     source_url: "https://github.com/mendrugory/conejo"]]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Conejo, []}]
  end

  defp description do
    """
    Conejo is an OTP application/library which will help you to define your AMQP/RabbitMQ publishers and consumers in an easier way.
    """
  end

  defp deps do
    [{:amqp, "~> 0.2.1"},
    {:confex, "~> 3.2.0"},
    {:earmark, ">= 0.0.0", only: :dev},
    {:ex_doc, ">= 0.0.0", only: :dev}]
  end

 defp package do
    [name: :conejo,
     maintainers: ["Gonzalo Jiménez Fuentes"],
     licenses: ["MIT License"],
     links: %{"GitHub" => "https://github.com/mendrugory/conejo"}]
  end
end
