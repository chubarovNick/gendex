defmodule Gendex.Parser do
  @moduledoc false

  alias Gendex.Entries

  require Logger

  @dict_path "priv/nam_dict.utf8.txt"

  @doc false
  def parse do
    default_path = Application.app_dir(:gendex, @dict_path)
    file = Application.get_env(:gendex, :dict_path, default_path)

    Logger.debug("Gendex parsing using dict_path at '#{file}'.")

    file
    |> File.stream!([:utf8])
    |> Enum.filter(&readable_line?/1)
    |> Enum.each(&parse_name_line/1)
  end

  defp parse_name_line(line) do
    [gender|[name|_]] =
      line
      |> String.split
      |> Enum.filter(fn(p) -> String.strip(p) != "" end)

    country_values = String.slice(line, 30, String.length(line))
    name = String.downcase(name)

    case gender do
      "M" -> Entries.set(name, :male, country_values)
      "1M" -> Entries.set(name, :mostly_male, country_values)
      "?M" -> Entries.set(name, :mostly_male, country_values)
      "F" -> Entries.set(name, :female, country_values)
      "1F" -> Entries.set(name, :mostly_female, country_values)
      "?F" -> Entries.set(name, :mostly_female, country_values)
      "?" -> Entries.set(name, :unisex, country_values)
      _ -> raise "Not sure what to do with a gender of #{gender}"
    end
  end

  defp readable_line?(line) do
    !String.starts_with?(line, "#") && !String.starts_with?(line, "=")
  end
end
