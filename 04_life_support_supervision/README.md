# Lesson 04: Life Support Supervision

This chapter is where the habitat stops being one overloaded process.

Atmosphere control, water recycling, and thermal regulation now live under their
own habitat supervision tree so one failure does not collapse the full habitat.

## What You'll Learn

- how to supervise sibling services with `:one_for_one`
- how to name children per habitat and subsystem
- how to prove restart isolation in tests

## Trying It Out

```bash
cd 04_life_support_supervision
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `life_support_supervision` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:life_support_supervision, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/life_support_supervision>.
