defmodule Gendex.Names do
  @moduledoc false

  @doc false
  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  @doc false
  def exists?(name), do: Agent.get __MODULE__, &Map.has_key?(&1, name)

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
        case Map.fetch(names, name) do
          {:ok, value} ->
            Map.put(names, name, value ++ [item])
          :error ->
            Map.put_new(names, name, [item])
        end
      end
    end
  end

  @doc false
  def all, do: Agent.get __MODULE__, &Map.to_list(&1)
end
