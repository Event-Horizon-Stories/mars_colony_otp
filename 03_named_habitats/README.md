# Lesson 03: The Colony Learns Names

Lesson 2 gave us one live habitat process.

This chapter keeps that model and solves the next pressure point: once the
colony has more than one habitat, it needs a way to address them by identity
instead of by whoever happens to be holding the PID.

Growth introduces a softer kind of danger: confusion. A place can fail simply
because the wrong door was opened too late.

## What You'll Learn

By the end of this lesson, you should understand:

- how to use `Registry` for process lookup
- how to run multiple instances of the same server module
- why runtime identity becomes important as soon as one process turns into many

## The Story

The colony is starting to spread.

New pressure doors open. New corridors are sealed and unsealed. One habitat
becomes several, and the settlement acquires the first feeling of distance
inside itself.

Names are how that distance stays human-sized.

They let a growing settlement remain speakable even as it becomes more than one
pair of hands can hold in memory.

There is no longer just one habitat keeping a crew alive. There are several,
and each one needs to be found by name:

- `hab-a`
- `hab-b`
- `lab-1`

A PID is not good enough as a public address. Operators need stable names.

## The OTP Concept

This chapter introduces `Registry` because it answers the next operational
question after `GenServer`:

> how do I find the right process later?

Once a system has multiple instances of the same module, identity becomes part
of the architecture.

## What We're Building

This chapter adds:

- [`lib/named_habitats/application.ex`](./lib/named_habitats/application.ex)
- [`lib/named_habitats/habitat_supervisor.ex`](./lib/named_habitats/habitat_supervisor.ex)
- registry-backed public APIs in [`lib/named_habitats.ex`](./lib/named_habitats.ex)

Each habitat is still the same basic server idea from lesson 2, but now the
colony can address many of them coherently.

## The Code

The lesson’s code lives in:

- [`lib/named_habitats.ex`](./lib/named_habitats.ex)
- [`lib/named_habitats/habitat_supervisor.ex`](./lib/named_habitats/habitat_supervisor.ex)
- [`test/named_habitats_test.exs`](./test/named_habitats_test.exs)

The public identity boundary shows up in the API:

```elixir
def start_habitat(id, opts \\ []) when is_binary(id) do
  HabitatSupervisor.start_habitat(id, opts)
end

def lookup_habitat(id) when is_binary(id) do
  case Registry.lookup(NamedHabitats.Registry, id) do
    # Return the PID if this habitat ID is registered.
    [{pid, _value}] -> {:ok, pid}
    # Return :error instead of crashing when the habitat is unknown.
    [] -> :error
  end
end

def get_status(id) when is_binary(id) do
  with {:ok, pid} <- lookup_habitat(id) do
    {:ok, Habitat.get_status(pid)}
  end
end
```

That moves the runtime contract away from raw PIDs and toward stable names.

The habitats themselves are now started under a `DynamicSupervisor`:

```elixir
defmodule NamedHabitats.HabitatSupervisor do
  use DynamicSupervisor

  def start_habitat(id, opts) do
    child_spec = {NamedHabitats.Habitat, Keyword.merge(opts, id: id)}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
```

That gives the colony a place to create habitats while still finding them later
by name.

## Trying It Out

Run the lesson:

```bash
cd 03_named_habitats
mix test
```

You can also inspect multiple habitats in `iex`:

```bash
cd 03_named_habitats
iex -S mix
```

Then:

```elixir
NamedHabitats.start_habitat("hab-a")
NamedHabitats.start_habitat("lab-1", oxygen: 80)

{:ok, hab_a} = NamedHabitats.get_status("hab-a")
{:ok, lab_1} = NamedHabitats.get_status("lab-1")

{hab_a.id, lab_1.id}
```

You should see separate running habitats that can be found by ID instead of by
raw PID.

## What the Tests Prove

The test suite in
[`test/named_habitats_test.exs`](./test/named_habitats_test.exs) proves three
things:

- multiple habitats can start under the same module
- each one can be found independently by ID
- state in one habitat does not leak into another

That separation is what makes runtime naming useful instead of cosmetic.

## Why This Matters

Adding more habitats is the first moment where the runtime stops feeling
singular.

It is also the moment where identity becomes part of the system design. The next
pressure comes quickly after that: a habitat is no longer just one process. It
is a small set of subsystems that should fail independently.

## OTP Takeaway

`Registry` is what lets a system grow from “a process” into “a set of
addressable processes.”

Once identity matters, naming becomes part of the architecture.

## What the Colony Can Do Now

The colony can now:

- run multiple habitats
- address them by stable IDs
- look them up later without passing PIDs around
- preserve runtime isolation between siblings

The colony finally has rooms instead of one sealed chamber.

## What Still Hurts

Each habitat is still too flat.

If water recycling crashes, the whole habitat process owns too much of the
blast radius.

## Next Lesson

[`04_life_support_supervision`](../04_life_support_supervision/README.md) turns
each habitat into a small supervision tree with restartable subsystems.
