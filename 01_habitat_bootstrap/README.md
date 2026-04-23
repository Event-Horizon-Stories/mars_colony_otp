# Lesson 01: The Habitat Learns Its Own Limits

The colony does not have a runtime yet. It barely has a shared language.

There is one habitat, one crew, and one growing pile of operational questions:

- how much oxygen is left
- when water becomes a problem
- which maintenance work is waiting
- how operators leave a visible trail of what changed

This lesson stays deliberately local. No processes. No supervisors. No runtime
identity. The goal is to make the habitat understandable before we make it
concurrent.

The first durable truths of a settlement are never heroic. They are counted in
air reserves, maintenance debt, and how honestly a room remembers its own strain.

## What You'll Learn

By the end of this lesson, you should understand:

- how to model domain state with a struct
- how to express operational changes as pure functions
- why explicit state transitions are the foundation under every later OTP lesson

## The Story

The first habitat on Mars is still run like a checklist on a wall.

Outside the shell, the planet keeps its distance with a patience older than the
species trying to inhabit it. Inside, survival is still intimate: a gauge, a
log entry, a maintenance note left for the next exhausted pair of hands.

A habitat begins as a discipline of attention before it becomes anything grand
enough to be called a frontier.

Mars makes ceremony out of ordinary care because ordinary care is what keeps
the frontier from becoming a graveyard.

Nobody is reasoning about process trees yet. They are trying to answer a
smaller question first:

> what is true about the habitat right now?

That means the system needs to track:

- oxygen
- water
- power
- crew count
- maintenance backlog
- a visible status log

The colony is not ready for a `GenServer` until that truth stops being vague.

## The OTP Concept

There is no OTP abstraction in play yet, and that is intentional.

This lesson teaches the discipline OTP builds on top of:

> before you make state concurrent, make it understandable.

If resource accounting is confusing in a pure module, wrapping it in a
`GenServer` will not fix it. It will only hide the confusion behind a PID.

## What We're Building

We will create:

- `HabitatBootstrap.Habitat`

The habitat can:

- consume oxygen, water, or power
- schedule maintenance
- update crew count
- record low-resource warnings when safety thresholds are crossed

## The Code

The lesson’s code lives in:

- [`lib/habitat_bootstrap/habitat.ex`](./lib/habitat_bootstrap/habitat.ex)
- [`test/habitat_test.exs`](./test/habitat_test.exs)

The full habitat struct shows the shape of state before OTP gets involved:

```elixir
defmodule HabitatBootstrap.Habitat do
  @moduledoc """
  Pure state transitions for a single habitat.
  """

  # We require a name because the rest of the tutorial keeps referring to
  # habitats as concrete places like "hab-a" or "lab-1".
  @enforce_keys [:name]
  defstruct name: nil,
            crew_count: 4,
            oxygen: 100,
            water: 100,
            power: 100,
            maintenance_backlog: [],
            status_log: []

  def new(name, opts \\ []) when is_binary(name) do
    struct!(__MODULE__, Keyword.merge([name: name], opts))
  end
end
```

The important part is not that this is a struct. The important part is that the
state is concrete and inspectable.

The core transition logic is still a plain function:

```elixir
def consume_resource(%__MODULE__{} = habitat, resource, amount)
    when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 do
  # Read the current resource value from the habitat state.
  current = Map.fetch!(habitat, resource)

  # Clamp the new value at zero so the model never goes negative.
  updated = max(current - amount, 0)

  habitat
  # Write the updated value back into the state.
  |> Map.put(resource, updated)
  # Record the operator-visible status change.
  |> add_status("#{resource} adjusted to #{updated}")
  # Add a safety warning if the resource crossed the danger threshold.
  |> maybe_add_low_resource_status(resource, updated)
end
```

That is the lesson in miniature. State changes are explicit before they are
concurrent.

## Trying It Out

Run the lesson:

```bash
cd 01_habitat_bootstrap
mix test
```

You can also inspect the habitat in `iex`:

```bash
cd 01_habitat_bootstrap
iex -S mix
```

Then:

```elixir
alias HabitatBootstrap.Habitat

habitat =
  "hab-a"
  |> Habitat.new()
  |> Habitat.consume_resource(:oxygen, 20)
  |> Habitat.consume_resource(:water, 80)
  |> Habitat.schedule_maintenance("co2 scrubber")
  |> Habitat.set_crew_count(6)

habitat
```

You should see one plain data structure that already tells a coherent
operational story.

## What the Tests Prove

The test suite in [`test/habitat_test.exs`](./test/habitat_test.exs) proves two
things:

- normal operational changes update the habitat predictably
- crossing a safety threshold leaves behind an explicit warning in state

That second point matters because later lessons will rely on these transitions
being stable.

## Why This Matters

The habitat does not need a mailbox yet.

It first needs rules that are easy to read, easy to test, and easy to trust.
Lesson 2 will keep the same operational model and place it behind a live
`GenServer`.

## OTP Takeaway

OTP starts paying off after the data model already makes sense.

Pure state transitions are not a detour away from concurrency. They are the
ground the runtime stands on.

## What the Colony Can Do Now

The colony can now:

- track one habitat’s core resources
- record maintenance work
- reflect staffing changes
- preserve a visible operational history

It is still small, but it is no longer vague.

## What Still Hurts

Everything is manual.

Every state transition happens in the caller’s hands. Nothing can stay alive,
nothing can receive messages, and nothing can be addressed as a running system.

That is the next problem.

## Next Lesson

[`02_habitat_server`](../02_habitat_server/README.md) keeps the same habitat
model and places it behind a `GenServer`.
