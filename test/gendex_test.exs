defmodule GendexTest do
  use ExUnit.Case

  test "should return correct gender" do
    assert Gendex.lookup("Bob") == :male
    assert Gendex.lookup("Sally") == :female
    assert Gendex.lookup("Pauley") == :unisex
  end

  test "should return correct gender for international name" do
    assert Gendex.lookup("Álfrún") == :female
    assert Gendex.lookup("Maëlle") == :female
  end

  test "should return true if name exists" do
    assert Gendex.name_exists?("Sally")
    assert Gendex.name_exists?("Carlos")
    assert Gendex.name_exists?("Rosario")
  end
end
