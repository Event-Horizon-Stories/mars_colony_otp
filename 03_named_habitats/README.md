# Lesson 03: Named Habitats

One habitat is not a colony.

This chapter adds a `Registry` so the runtime can address multiple habitats by
stable IDs instead of passing PIDs around manually.

## What You'll Learn

- how to register processes by habitat ID
- how to start multiple instances of the same module
- why naming is the next problem after a single live server works

## Trying It Out

```bash
cd 03_named_habitats
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `named_habitats` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:named_habitats, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/named_habitats>.
