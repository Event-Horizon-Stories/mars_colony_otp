# Lesson 06: Dynamic Rovers

Rovers should not all exist at boot.

This chapter introduces a `DynamicSupervisor` so the colony can launch survey,
repair, and cargo rovers only when missions actually exist.

## What You'll Learn

- how to supervise runtime-created workers
- why on-demand workers are different from static boot children
- how to retire a worker cleanly when its mission ends

## Trying It Out

```bash
cd 06_dynamic_rovers
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dynamic_rovers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dynamic_rovers, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/dynamic_rovers>.
