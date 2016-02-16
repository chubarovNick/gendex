defmodule Gendex.Names do
  @moduledoc false

  alias Gendex.Parser

  @doc false
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  @doc false
  def exists?(name), do: get |> Map.has_key?(name)

  @doc false
  def get do
    names = Agent.get __MODULE__, &(&1)
    if Enum.empty?(names) do
      Parser.parse
      get
    else
      names
    end
  end

  @doc false
  def set(name, gender, country_values) do
    if String.contains?(name, "+") do
      # In nam_dict.utf8.txt, a plus char ('+') "inside" a name
      # symbolizes a '-', ' ' or an empty string
      # (this option applies to Arabic, Chinese and Korean names only).
      # Thus, "Jun+Wei" represents the names "Jun-Wei", "Jun Wei" and "Junwei".
      Enum.each ["", "-", " "], fn (r) ->
        set(String.replace(name, "+", r), gender, country_values)
      end
    else
      item = {gender, country_values}
      Agent.update __MODULE__, fn(names) ->
        if Map.has_key?(names, name) do
          n = Map.get(names, name) ++ [item]
          Map.put(names, name, n)
        else
          Map.put_new(names, name, [item])
        end
      end
    end
  end

  @doc false
  def all, do: get |> Map.to_list
end
