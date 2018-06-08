defmodule Conejo.Mixfile do
  use Mix.Project

  @version "0.5.0"

  def project do
    [
      app: :conejo,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/mendrugory/conejo",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Conejo, []}]
  end

  defp description do
    """
    Conejo is an OTP application/library which will help you to define your AMQP/RabbitMQ publishers and consumers in an easier way.
    """
  end

  defp deps do
    [
      {:amqp, "~> 1.0.3"},
      {:confex, "~> 3.2.0"},
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: :conejo,
      maintainers: ["Gonzalo Jiménez Fuentes"],
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/mendrugory/conejo"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib","test"] 
  defp elixirc_paths(_), do: ["lib"] 
end
