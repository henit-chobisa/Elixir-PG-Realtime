defmodule PostgresListener.MixProject do
  use Mix.Project

  def project do
    [
      app: :pglistener,
      name: "Plane Pg Listener",
      version: "0.1.0",
      build_embedded: Mix.env() == :prod,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "~> 0.17"},
      {:decimal, "~> 2.1.1"},
      {:ex_doc, "~> 0.30.4", only: :dev, runtime: false},
      {:jason, "~> 1.4"},
      {:map_diff, "~> 1.3"},
      {:retry, "~> 0.18.0"},
      {:timex, "~> 3.7"}
    ]
  end
end
