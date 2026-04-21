# Lesson 13: Incident Commander

The colony now knows enough to do more than restart crashed processes.

This chapter adds a coordinator that listens for alerts, records incident state,
and dispatches response work across subsystems.

## What You'll Learn

- how one process can orchestrate a multi-step response
- where coordination state belongs during an incident
- how alerts and action queues stay separate but connected

## Trying It Out

```bash
cd 13_incident_commander
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `incident_commander` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:incident_commander, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/incident_commander>.
