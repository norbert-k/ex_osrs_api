defmodule ExOsrsApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_osrs_api,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExOsrsApi",
      docs: [
        extras: ["README.md"]
      ],
      dialyzer: [flags: [:error_handling, :race_conditions, :underspecs]],
      description: description(),
      package: package(),
      source_url: "https://github.com/norbert-k/ex_osrs_api"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :fuse, :ex_rated],
      mod: {ExOsrsApi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4.0"},
      {:hackney, "~> 1.17.0"},
      {:fuse, "~> 2.4"},
      {:ex_rated, "~> 1.2"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    "OSRS Old school runescape Highscore API wrapper"
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/norbert-k/ex_osrs_api"}
    ]
  end
end
