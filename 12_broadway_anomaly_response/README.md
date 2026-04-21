# Lesson 12: Broadway Anomaly Response

By this point the telemetry stream has stopped looking like a hand-built demo.

This chapter rebuilds anomaly handling as a Broadway pipeline so batching and
concurrency become part of the runtime contract instead of custom queue code.

## What You'll Learn

- how Broadway sits on top of streaming producers
- where batching belongs in an event pipeline
- how to keep the example practical instead of abstract

## Trying It Out

```bash
cd 12_broadway_anomaly_response
mix deps.get
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `broadway_anomaly_response` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:broadway_anomaly_response, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/broadway_anomaly_response>.
