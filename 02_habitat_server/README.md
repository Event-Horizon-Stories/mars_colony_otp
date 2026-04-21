# Lesson 02: Habitat Server

In lesson 1, the habitat became understandable.

In lesson 2, the habitat becomes live.

The same operational state now sits behind a `GenServer` that can receive calls
and casts from the outside world.

## What You'll Learn

- how to turn one stateful component into a `GenServer`
- when to use `call` versus `cast`
- how a lesson-specific `Application` starts the runtime

## Trying It Out

```bash
cd 02_habitat_server
mix test
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `habitat_server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:habitat_server, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/habitat_server>.
