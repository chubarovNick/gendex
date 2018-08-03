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
    [gender | [name | _]] =
      line
      |> String.split()
      |> Enum.filter(fn p -> String.trim(p) != "" end)

    country_values =
      line
      |> String.slice(30, String.length(line))
      |> String.split("")
      |> Enum.reduce([], fn country_value, acc ->
        if Enum.member?(["\n", "", " ", "$"], country_value) do
          acc
        else
          number =
            country_value
            |> decode_name_friqency()

          [ number | acc]
        end
      end)

    name = String.downcase(name)

    gender =
      case gender do
        "M" -> :male
        "1M" -> :mostly_male
        "?M" -> :mostly_male
        "F" -> :female
        "1F" -> :mostly_female
        "?F" -> :mostly_female
        "?" -> :unisex
        _ -> raise "Not sure what to do with a gender of #{gender}"
      end

    Entries.set(name, gender, country_values)
  end

  defp readable_line?(line) do
    !String.starts_with?(line, "#") && !String.starts_with?(line, "=")
  end

  defp decode_name_friqency(f) do
    "0#{f}"
    |> Base.decode16!()
    |> :binary.decode_unsigned()
  end
end
