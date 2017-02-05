defmodule Checksum.Mixfile do
  use Mix.Project

  def project do
    [app: :checksum,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
   """
   Checksum library allows checksum calculations, like CRC....
   """
   end

  defp package do
    [
      name: :checksum,
      files: ["config", "lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Daniel Seidler"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/danseid/checksum",
               "Docs" => "https://hexdocs.pm/checksum"}
    ]
  end
end
