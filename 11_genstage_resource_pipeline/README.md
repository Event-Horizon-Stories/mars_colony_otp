# Lesson 11: GenStage Resource Pipeline

The colony's sensor stream is now large enough to deserve a demand-driven
pipeline instead of ad hoc message fan-out.

This chapter moves telemetry through a `GenStage` producer, a normalization
stage, and an anomaly sink.

## What You'll Learn

- how demand flows from consumers back to producers
- when a producer-consumer stage is useful
- how to keep streaming transformations narrow and testable

## Trying It Out

```bash
cd 11_genstage_resource_pipeline
mix deps.get
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `genstage_resource_pipeline` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:genstage_resource_pipeline, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/genstage_resource_pipeline>.
