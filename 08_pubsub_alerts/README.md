# Lesson 08: PubSub Alerts

The colony now has events that multiple teams care about at once.

This chapter uses a duplicate `Registry` as a small local event bus so habitat
alarms can fan out to whoever is listening.

## What You'll Learn

- how to broadcast locally without hard-coding receivers
- why subscriptions reduce coupling between publishers and listeners
- how to prove fan-out behavior in tests

## Trying It Out

```bash
cd 08_pubsub_alerts
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pubsub_alerts` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pubsub_alerts, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pubsub_alerts>.
