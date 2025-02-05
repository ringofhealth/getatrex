defmodule Getatrex.Mixfile do
  use Mix.Project

  @version "0.1.2"

  def project do
    [
      app: :getatrex,
      version: @version,
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"],
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/alexfilatov/getatrex",
      name: "Getatrex",
      docs: [source_ref: "v#{@version}", main: "readme", extras: ["README.md"]],
      description: description(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :hackney]]
  end

  defp deps do
    [
      {:gettext, "~> 0.22"},
      {:tesla, "~> 1.4"},

      # optional, but recommended adapter
      {:hackney, "~> 1.17"},

      # optional, required by JSON middleware
      {:jason, "~> 1.4"},
      {:goth, "~> 1.4"},
      {:remix, "~> 0.0.2", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:mock, "~> 0.3", only: :test},
      {:excoveralls, "~> 0.16", only: :test},
      {:ex_doc, "~> 0.29", only: :dev}
    ]
  end

  defp description do
    "Automatic Gettext locale translator for Elixir/Phoenix projects."
  end

  defp package do
    [
      maintainers: ["Alex Filatov"],
      licenses: ["Apache 2.0"],
      links: %{"Github" => "https://github.com/alexfilatov/getatrex"},
      docs: [
        source_ref: "v#{@version}",
        source_url: "https://github.com/alexfilatov/getatrex",
        dependencies: [
          ex_doc: "~> 0.29.4"
        ]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]
end
