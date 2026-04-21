# Lesson 06: The Surface Fleet Comes Online

Static boot-time children are not enough anymore.

By lesson 5, the colony already has a real root tree: habitats, mission control,
storage, and communications. Now surface work starts appearing and disappearing
during runtime. Rovers should exist when there is a mission, not because the
application happened to start.

## What You'll Learn

By the end of this lesson, you should understand:

- how to use `DynamicSupervisor` for runtime-created workers
- how to give dynamic children stable public identities
- why some children should be temporary instead of restartable forever

## The Story

The colony is expanding outward from the habitats.

Rovers are the first workers in the series whose lifecycle is driven by demand:

- a mission appears
- a rover is launched
- the rover gets an assignment
- the rover retires when the mission ends

That is a different shape from habitat services. Atmosphere control should
always exist. A ridge survey rover should not.

## The OTP Concept

This chapter introduces a practical distinction:

> some processes represent standing capability, and some represent temporary work.

`DynamicSupervisor` is the right tool when the runtime must create workers on
demand and clean them up without mutating the boot-time tree.

## What We're Building

This chapter keeps the entire colony control tree from lesson 5 and adds:

- `DynamicRovers.RoverSupervisor`
- `DynamicRovers.Rover`
- runtime APIs for launch, assignment, lookup, and retirement

Each rover is a supervised process with a mission and status, but its lifetime
is bounded by the job it was created to perform.

## The Code

The lesson’s code lives in:

- [`lib/dynamic_rovers/rover_supervisor.ex`](./lib/dynamic_rovers/rover_supervisor.ex)
- [`lib/dynamic_rovers/rover.ex`](./lib/dynamic_rovers/rover.ex)
- [`lib/dynamic_rovers.ex`](./lib/dynamic_rovers.ex)
- [`test/dynamic_rovers_test.exs`](./test/dynamic_rovers_test.exs)

The on-demand lifecycle shows up in the supervisor API:

```elixir
def launch_rover(id, opts) do
  child_spec =
    Supervisor.child_spec(
      # Start a rover with its runtime mission options.
      {DynamicRovers.Rover, Keyword.merge(opts, id: id)},
      id: {:rover, id},
      # When a rover is retired, it should stay retired.
      restart: :temporary
    )

  DynamicSupervisor.start_child(__MODULE__, child_spec)
end
```

That `restart: :temporary` line matters as much as the `DynamicSupervisor`
itself.

The public API keeps the dynamic worker easy to address:

```elixir
def launch_rover(id, opts \\ []) when is_binary(id) do
  RoverSupervisor.launch_rover(id, opts)
end

def rover_status(id) when is_binary(id) do
  with {:ok, pid} <- lookup_rover(id) do
    {:ok, Rover.status(pid)}
  end
end

def retire_rover(id) when is_binary(id) do
  with {:ok, pid} <- lookup_rover(id) do
    monitor = Process.monitor(pid)
    :ok = DynamicSupervisor.terminate_child(DynamicRovers.RoverSupervisor, pid)

    receive do
      # Wait until the rover process actually dies before reporting success.
      {:DOWN, ^monitor, :process, ^pid, _reason} -> await_rover_removal(id)
    after
      100 -> await_rover_removal(id)
    end
  end
end
```

That makes the full rover lifecycle visible instead of hand-wavy.

## Trying It Out

Run the lesson:

```bash
cd 06_dynamic_rovers
mix test
```

You can also inspect the rover lifecycle in `iex`:

```bash
cd 06_dynamic_rovers
iex -S mix
```

Then:

```elixir
{:ok, _} = DynamicRovers.start_habitat("hab-a")
{:ok, _pid} = DynamicRovers.launch_rover("rover-7", mission: "ridge survey")

DynamicRovers.assign_mission("rover-7", "ridge survey")
DynamicRovers.rover_status("rover-7")

:ok = DynamicRovers.retire_rover("rover-7")
DynamicRovers.lookup_rover("rover-7")
```

You should see the rover appear for the mission and disappear cleanly when its
work is over.

## What the Tests Prove

The test suite in
[`test/dynamic_rovers_test.exs`](./test/dynamic_rovers_test.exs) proves the full
rover lifecycle:

- a rover can be launched at runtime
- it can receive a mission
- its state can be queried by ID
- it disappears cleanly when retired

That last point matters because temporary workers should not silently restart
and pretend retirement never happened.

## Why This Matters

The colony can now create runtime workers when reality demands them.

That raises the next design question: what work should not become a long-lived
process at all?

Lesson 7 answers that with short-lived tasks and explicit timeouts.

## OTP Takeaway

`DynamicSupervisor` is what you reach for when workers are born from runtime
demand instead of boot-time certainty.

It is not “more supervision.” It is a different lifecycle model.

## What the Colony Can Do Now

The colony can now:

- keep a stable habitat and operations tree
- create rovers only when missions appear
- assign and inspect rover work by ID
- retire temporary workers without restart churn

The runtime now has moving parts that come and go with the day.

## What Still Hurts

Not every new piece of work should become a named process.

Some jobs are just expensive calculations with a timeout boundary, and keeping
them alive after the answer comes back would be wasteful.

## Next Lesson

[`07_tasks_and_timeouts`](../07_tasks_and_timeouts/README.md) introduces
supervised tasks for bursty work such as route planning.
