defmodule Gendex.Entries do
  @moduledoc false

  @table :gendex_entries

  @doc false
  def start_link,
    do: :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])

  @doc false
  def has_key?(name),
    do: :ets.member(@table, name)

  @doc false
  def all,
    do: :ets.tab2list(@table)

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
      item = [{gender, country_values}]
      if has_key?(name) do
        item = :ets.lookup_element(@table, name, 2) ++ item
      end

      :ets.insert(@table, {name, item})
    end
  end
end
