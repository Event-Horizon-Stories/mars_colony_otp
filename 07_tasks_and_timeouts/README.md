# Lesson 07: Tasks and Timeouts

Not every unit of work deserves a permanent process.

Route planning and weather analysis are bursty, so this chapter runs them under
`Task.Supervisor` and makes timeout behavior explicit.

## What You'll Learn

- when a `Task` is a better fit than a long-lived `GenServer`
- how to run async work under supervision
- why timeout handling is part of the API contract

## Trying It Out

```bash
cd 07_tasks_and_timeouts
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tasks_and_timeouts` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tasks_and_timeouts, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/tasks_and_timeouts>.
