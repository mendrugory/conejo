defmodule Conejo.Mixfile do
  use Mix.Project

  def project do
    [app: :conejo,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :amqp_client, :amqp],
     mod: {Conejo, []}]
  end

  defp deps do
    [{:amqp_client, git: "https://github.com/mendrugory/amqp_client.git", branch: "erlang_otp_19", override: true},
    {:amqp, "~> 0.1.5"}]
  end
end
