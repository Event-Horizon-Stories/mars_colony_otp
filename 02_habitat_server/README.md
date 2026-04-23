# Lesson 02: The Habitat Goes Live

In lesson 1, the habitat became understandable.

In lesson 2, the habitat becomes live.

The resource logic stays the same in spirit, but the habitat now lives behind a
`GenServer`. The caller no longer threads state forward by hand. The process
owns it.

## What You'll Learn

By the end of this lesson, you should understand:

- how to implement a simple `GenServer`
- how `call` and `cast` differ
- how OTP turns a stateful module into a long-lived runtime participant

## The Story

One habitat is no longer enough as a ledger in a notebook.

There comes a point in any hard place when keeping track by hand begins to feel
like superstition. The room has to keep its own truth between visits. Operators
need the habitat to stay alive, answer questions, and accept updates over time.
That is a different requirement from lesson 1. We do not just want a data
structure anymore. We want a long-lived service.

Continuity is a kind of trust. On Mars, trust has to survive the moment when no
one is looking directly at the system that keeps them alive.

## The OTP Concept

`GenServer` is the first major OTP abstraction in the series because it solves
the first real runtime problem:

> who owns this state between calls?

In lesson 1, the caller owned everything. In lesson 2, the habitat process owns
its own state and exposes a message-based API.

## What We're Building

We will create:

- `HabitatServer.Habitat`
- a small public API in [`lib/habitat_server.ex`](./lib/habitat_server.ex)
- [`lib/habitat_server/application.ex`](./lib/habitat_server/application.ex)

The habitat can now:

- start as a named process
- answer synchronous status queries
- handle resource changes
- update crew count
- accept asynchronous maintenance scheduling

## The Code

The lesson’s code lives in:

- [`lib/habitat_server/habitat.ex`](./lib/habitat_server/habitat.ex)
- [`lib/habitat_server.ex`](./lib/habitat_server.ex)
- [`test/habitat_server_live_test.exs`](./test/habitat_server_live_test.exs)

The public API is intentionally small, because the `GenServer` should expose the
habitat’s operations, not its implementation details:

```elixir
defmodule HabitatServer do
  @moduledoc """
  Public API for the live habitat lesson.
  """

  alias HabitatServer.Habitat

  # Boot one long-lived habitat process.
  defdelegate start_link(opts), to: Habitat

  # Synchronous read: the caller wants the latest state back now.
  defdelegate get_status(server), to: Habitat

  # Synchronous write: the caller wants the updated resource state immediately.
  defdelegate consume_resource(server, resource, amount), to: Habitat

  # Synchronous write: staffing still matters in the live habitat.
  defdelegate set_crew_count(server, crew_count), to: Habitat

  # Asynchronous write: maintenance can be scheduled without blocking the caller.
  defdelegate schedule_maintenance(server, system), to: Habitat
end
```

The state transition from lesson 1 moves behind server callbacks:

```elixir
def handle_call({:consume_resource, resource, amount}, _from, state)
    when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 do
  # Read the current resource value from the process state.
  updated = max(Map.fetch!(state, resource) - amount, 0)

  next_state =
    state
    # Persist the new value inside the running server.
    |> Map.put(resource, updated)
    # Keep the same operator-facing audit trail from lesson 1.
    |> append_status("#{resource} adjusted to #{updated}")
    # Keep the same low-resource warning behavior from lesson 1.
    |> maybe_add_low_resource_status(resource, updated)

  # Reply with the new state and keep it as the server state.
  {:reply, next_state, next_state}
end

def handle_call({:set_crew_count, crew_count}, _from, state)
    when is_integer(crew_count) and crew_count > 0 do
  next_state =
    state
    |> Map.put(:crew_count, crew_count)
    |> append_status("crew count set to #{crew_count}")

  {:reply, next_state, next_state}
end

def handle_cast({:schedule_maintenance, system}, state) do
  next_state =
    state
    |> Map.update!(:maintenance_backlog, &(&1 ++ [system]))
    |> append_status("maintenance scheduled for #{system}")

  # No reply is sent because a cast is fire-and-forget.
  {:noreply, next_state}
end
```

The caller is no longer carrying the state. The process is.

## Trying It Out

Run the lesson:

```bash
cd 02_habitat_server
mix test
```

You can also run the habitat in `iex`:

```bash
cd 02_habitat_server
iex -S mix
```

Then:

```elixir
{:ok, _pid} =
  HabitatServer.start_link(
    name: :habitat_a,
    habitat_name: "hab-a",
    crew_count: 4,
    oxygen: 100,
    water: 100,
    power: 100
  )

HabitatServer.consume_resource(:habitat_a, :oxygen, 80)
HabitatServer.set_crew_count(:habitat_a, 6)
HabitatServer.schedule_maintenance(:habitat_a, "water recycler")
HabitatServer.get_status(:habitat_a)
```

You should see a live habitat whose state survives between calls.

## What the Tests Prove

The test suite in
[`test/habitat_server_live_test.exs`](./test/habitat_server_live_test.exs)
proves four things:

- synchronous calls can read and mutate habitat state
- asynchronous casts can add maintenance work without blocking the caller
- the live habitat still records crew changes and low-resource warnings
- the habitat behaves like the same operational model from lesson 1, only now as
  a running process

That last point matters. OTP did not replace the domain logic. It operationalized it.

## Why This Matters

Lesson 1 gave us clarity. Lesson 2 gives that clarity a mailbox.

Once state lives inside a process, the next pressure appears immediately: how do
we run more than one habitat without losing track of which is which?

## OTP Takeaway

`GenServer` is what turns “state we pass around” into “state with a home.”

That is the first real runtime boundary in the series.

## What the Colony Can Do Now

The colony can now:

- run one habitat as a process
- query it synchronously
- mutate it through messages
- let state persist inside the runtime

The system finally has something alive inside it.

## What Still Hurts

There is still only one obvious habitat.

As soon as the colony adds a second module of living space, the real question
becomes identity: which habitat are we talking to?

## Next Lesson

[`03_named_habitats`](../03_named_habitats/README.md) keeps the live habitat and
adds runtime naming with `Registry`.
