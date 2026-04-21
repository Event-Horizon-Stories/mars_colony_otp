# Lesson 10: Telemetry and Observability

The colony is now operationally real enough that operators need measurements,
not guesses.

This chapter emits `:telemetry` events from the maintenance queue so queue depth
and dispatch behavior become visible without scraping process state.

## What You'll Learn

- how to emit `:telemetry` events at runtime boundaries
- what belongs in measurements versus metadata
- how to test instrumentation directly

## Trying It Out

```bash
cd 10_telemetry_and_observability
mix deps.get
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `telemetry_and_observability` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:telemetry_and_observability, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/telemetry_and_observability>.
