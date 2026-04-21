defmodule DistributedOutposts.MixProject do
  use Mix.Project

  def project do
    [
      app: :distributed_outposts,
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
      mod: {DistributedOutposts.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 1.1"}
    ]
  end
end
