# Gendex

[![Build Status](https://img.shields.io/travis/dre1080/gendex.svg?style=flat-square)](https://travis-ci.org/dre1080/gendex) [![Hex.pm](https://img.shields.io/hexpm/v/gendex.svg?style=flat-square)](https://hex.pm/packages/gendex)

Gendex is an Elixir library that will tell you the most likely gender of a person based on their first name.
It uses a UTF-8 encoded version of the underlying data from the program "gender" by Jorg Michael (described [here](http://www.autohotkey.com/community/viewtopic.php?t=22000)).

Inspired by [Gender Detector](https://github.com/bmuller/gender_detector).

## Installation

First, add Gendex to your `mix.exs` dependencies:

```elixir
def deps do
  [{:gendex, "~> 0.4.0"}]
end
```

And start the Gendex application. For most projects (such as
Phoenix apps) this will mean adding `:gendex` to the list of applications in
`mix.exs`.

```elixir
def application do
  [mod: {MyApp, []},
   applications: [:gendex, :other_apps...]]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

Optionally, you can also set the path to your own `nam_dict.txt` (utf8 encoded)
by adding this to your config:

```elixir
config :gendex, dict_path: "/path/to/custom/dict"
```

## Usage

```elixir
Gendex.lookup("Bob")
#=> :male

Gendex.lookup("Sally")
#=> :female

Gendex.lookup("Pauley")
#=> :unisex
```

## TODO

- [] Country specific gender lookup
