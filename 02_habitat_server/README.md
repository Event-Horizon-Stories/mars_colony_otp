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
