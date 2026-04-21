defmodule BroadwayAnomalyResponse.MixProject do
  use Mix.Project

  def project do
    [
      app: :broadway_anomaly_response,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer],
      mod: {BroadwayAnomalyResponse.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 1.1"}
    ]
  end
end
