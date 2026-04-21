# Lesson 14: Persistent Shift Handoff

At some point the colony has to survive restarts without losing the operational
story of the last shift.

This chapter persists selected incident summaries to disk and restores them on
boot, without turning the tutorial into a database course.

## What You'll Learn

- how to introduce a narrow persistence boundary
- why not every process state deserves durability
- how to verify restart recovery in tests

## Trying It Out

```bash
cd 14_persistent_shift_handoff
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `persistent_shift_handoff` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:persistent_shift_handoff, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/persistent_shift_handoff>.
