defmodule Gendex.Parser do
  @moduledoc false

  alias Gendex.Names

  @dict_path "priv/nam_dict.utf8.txt"

  @doc false
  def parse do
    file = Application.get_env(:gendex, :dict_path, @dict_path)
    file
    |> File.stream!([:utf8])
    |> Stream.filter(&readable_line?/1)
    |> Stream.each(&parse_name_line/1)
    |> Stream.run
  end

  defp parse_name_line(line) do
    [gender|[name|_]] =
      line
      |> String.split
      |> Enum.filter(fn(p) -> String.strip(p) != "" end)

    country_values = String.slice(line, 30, String.length(line))
    name = String.downcase(name)

    case gender do
      "M" -> Names.set(name, :male, country_values)
      "1M" -> Names.set(name, :mostly_male, country_values)
      "?M" -> Names.set(name, :mostly_male, country_values)
      "F" -> Names.set(name, :female, country_values)
      "1F" -> Names.set(name, :mostly_female, country_values)
      "?F" -> Names.set(name, :mostly_female, country_values)
      "?" -> Names.set(name, :unisex, country_values)
      _ -> raise "Not sure what to do with a gender of #{gender}"
    end
  end

  defp readable_line?(line) do
    !String.starts_with?(line, "#") && !String.starts_with?(line, "=")
  end
end
