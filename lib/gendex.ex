defmodule Gendex do
  @moduledoc """
  Gendex is a library that will tell you the most likely gender
  of a person based on first name.

  It uses the underlying data from the program "gender"
  by Jorg Michael (described [here](http://www.autohotkey.com/community/viewtopic.php?t=22000)).

  ## Examples

      iex> Gendex.lookup("Bob")
      :male

      iex> Gendex.lookup("Sally")
      :female

      iex> Gendex.lookup("Pauley")
      :unisex
  """

  use Application

  alias Gendex.Entries
  alias Gendex.Parser

  @doc false
  def start(_type, _args) do
    Entries.start_link()

    if Application.get_env(:gendex, :spawn_parser) do
      spawn(Parser, :parse, [])
    else
      Parser.parse()
    end

    {:ok, self()}
  end

  @doc """
  Gets the gender of the given name.

  ## Examples

      iex> Gendex.lookup("James")
      :male

      iex> Gendex.lookup("Unavailable")
      :unknown
  """
  def lookup(name), do: name |> String.downcase() |> most_likely_gender

  @doc """
  Checks whether a name exists in `Gendex.Entries`.

  Returns `true` if it exists, otherwise `false`.

  ## Examples

      iex> Gendex.name_exists?("James")
      true

      iex> Gendex.name_exists?("Unknown")
      false
  """
  def name_exists?(name), do: name |> String.downcase() |> Entries.has_key?()

  defp most_likely_gender(name) do
    case Entries.lookup(name) do
      [{_, entries} | _] ->
        choose_more_friquent_result(entries)

      _ ->
        :unknown
    end
  end

  defp choose_more_friquent_result(entries) do
    {gender, _} =
      Enum.max_by(entries, fn entry ->
        {_, country_values} = entry

        country_values
        |> length
      end)

    gender
  end
end
