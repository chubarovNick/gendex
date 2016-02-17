defmodule Gendex do
  @moduledoc """
  Gendex is a library that will tell you the most likely gender
  of a person based on first name.

  It uses the underlying data from the program “gender”
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

  alias Gendex.Names

  @doc false
  def start(_type, _args), do: Names.start_link

  @doc """
  Gets the gender of the given name.

  ## Examples

      iex> Gendex.lookup("James")
      :male

      iex> Gendex.lookup("Unavailable")
      :unknown
  """
  def lookup(name), do: name |> String.downcase |> most_popular_gender

  @doc """
  Checks whether a name exists in `Gendex.Names`.

  Returns `true` if it exists, otherwise `false`.

  ## Examples

      iex> Gendex.name_exists?("James")
      true

      iex> Gendex.name_exists?("Unknown")
      false
  """
  def name_exists?(name), do: name |> String.downcase |> Names.exists?

  defp most_popular_gender(name) do
    if name_exists?(name) do
      [{_, matches}|_] = Enum.filter Names.all, fn(x) ->
        case x do
          {^name, _} -> true
          _ -> false
        end
      end

      {gender, _} = Enum.max_by matches, fn(match) ->
        {_, country_values} = match

        country_values
        |> String.split("")
        |> Enum.filter(fn(x) -> String.strip(x) != "" end)
        |> length
      end
      gender
    else
      :unknown
    end
  end
end
