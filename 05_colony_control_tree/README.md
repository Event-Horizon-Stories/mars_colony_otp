# Lesson 05: Colony Control Tree

This is the point where the system starts looking like a colony instead of a
single habitat with helpers.

Mission control, storage, and communications now boot under separate top-level
branches so the runtime can grow by domain instead of by accident.

## What You'll Learn

- how to compose a top-level supervision tree
- why domains deserve separate branches
- how to verify that one branch crash does not take down the others

## Trying It Out

```bash
cd 05_colony_control_tree
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `colony_control_tree` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:colony_control_tree, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/colony_control_tree>.
