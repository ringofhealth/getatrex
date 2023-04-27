defmodule Mix.Tasks.Getatrex do
  @moduledoc """
  Runs locale translation routine
  """
  use Mix.Task

  @shortdoc "Translates gettext locale with Google Cloud Translate API"

  @doc """
  Runs the routine

  1. Check whether target locale exists, files errors.po, default.po
  2. Start reading `default.po` in the stream
  3. Collect translation groups by comments(location in templates) + msgid line(original) + msgstr line(translated)
  4. When translation group is collected - translate and save to msgstr line
  5. When translation is done - write group to disk
  6. When translation failed - write not translated group to disk (to re-run this later)
  7. All read/write are sync (to respect the order)
  8.
  """
  def run([to_lang | _tail]) do
    # checking whether local exists and run if file exists
    to_lang
    |> locale_path_default_po()
    |> File.exists?()
    |> run_with_file(to_lang)
  end

  def run_with_file(file_exists, to_lang) when file_exists == false or file_exists == nil do
    Mix.shell().info("Warning!")
    Mix.shell().info("Locale filename #{locale_path_default_po(to_lang)} does not exists.")
    Mix.shell().info("Please create '#{to_lang}' locale with gettext first:")
    Mix.shell().info("Follow the instructions:")
    Mix.shell().info("")
    Mix.shell().info("$ mix gettext.extract")
    Mix.shell().info("$ mix gettext.merge priv/gettext")
    Mix.shell().info("$ mix gettext.merge priv/gettext --locale #{to_lang}")
    Mix.shell().info("")
    Mix.shell().info("More info here: https://github.com/elixir-lang/gettext#workflow")
  end

  def run_with_file(true, to_lang) do
    Mix.shell().info("Starting translation gettext locale #{to_lang}")

    to_lang
    |> translated_locale_path_default_po()
    |> Getatrex.Writer.start_link()

    Getatrex.Collector.start_link(to_lang)

    to_lang
    |> locale_path_default_po()
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Stream.map(fn {line, i} ->
      IO.puts("#{i}: #{line}")
      Getatrex.Collector.dispatch_line(line)
    end)
    |> Stream.run()

    Getatrex.Collector.dispatch_line("")
    Mix.shell().info("Done!")
  end

  def run(_), do: run()

  def run do
    Mix.shell().info("Call this task in the following way:")
    Mix.shell().info("")
    Mix.shell().info("\t$ mix getatrex es")
    Mix.shell().info("")

    Mix.shell().info(
      "where `es` - target language (should be created by gettext before getatrex)"
    )

    Mix.shell().info("")

    Mix.shell().info(
      "Please read README.md https://github.com/alexfilatov/getatrex#getting-started"
    )
  end

  @doc """
  Returns path to the locale generated by gettext
  """
  def locale_path_default_po(to_lang) do
    "./priv/gettext/#{to_lang}/LC_MESSAGES/default.po"
  end

  @doc """
  Returns path for translated locale
  """
  def translated_locale_path_default_po(to_lang) do
    "./priv/gettext/#{to_lang}/LC_MESSAGES/translated_default.po"
  end
end
