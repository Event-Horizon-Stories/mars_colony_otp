# Lesson 04: A Habitat Grows an Inner Skeleton

The colony now has multiple named habitats. That solves identity, but not
failure boundaries.

In a real habitat, atmosphere control, water recycling, and thermal regulation
should not all rise and fall together. This chapter gives each habitat an inner
skeleton: a supervisor with multiple child services. By this point, survival is
no longer one machine doing one thing well. It is a set of promises that must
fail separately if life is to continue.

## What You'll Learn

By the end of this lesson, you should understand:

- how to build a `Supervisor` with child specs
- how `:one_for_one` restart strategy isolates sibling failures
- why supervision is about blast radius, not just startup convenience

## The Story

Each habitat is starting to feel less like one box and more like a machine made
of smaller machines.

To live anywhere harsh, a system has to learn the difference between injury and
death.

Three subsystems matter immediately:

- atmosphere control
- water recycling
- thermal control

If thermal control crashes, the habitat should not lose atmosphere control in
the process. The colony needs local healing, not global collapse.

## The OTP Concept

This chapter introduces `Supervisor` as OTP’s answer to a new question:

> what should restart together, and what should fail alone?

Supervision is not just a boot pattern. It is a statement about failure
boundaries.

## What We're Building

This chapter adds:

- [`lib/life_support_supervision/habitat_supervisor.ex`](./lib/life_support_supervision/habitat_supervisor.ex)
- [`lib/life_support_supervision/life_support_unit.ex`](./lib/life_support_supervision/life_support_unit.ex)
- [`lib/life_support_supervision/habitat_fleet.ex`](./lib/life_support_supervision/habitat_fleet.ex)

The colony keeps the fleet shape from lesson 3, but the teaching focus shifts
from one habitat status server to the supervised subsystem tree inside each
habitat.

## The Code

The lesson’s code lives in:

- [`lib/life_support_supervision.ex`](./lib/life_support_supervision.ex)
- [`lib/life_support_supervision/habitat_supervisor.ex`](./lib/life_support_supervision/habitat_supervisor.ex)
- [`lib/life_support_supervision/life_support_unit.ex`](./lib/life_support_supervision/life_support_unit.ex)
- [`test/life_support_supervision_test.exs`](./test/life_support_supervision_test.exs)

The key design decision is in the habitat supervisor:

```elixir
@impl true
def init(id) do
  children = [
    Supervisor.child_spec(
      # Atmosphere is one independently restartable service.
      {LifeSupportSupervision.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
      id: {LifeSupportSupervision.LifeSupportUnit, id, :atmosphere}
    ),
    Supervisor.child_spec(
      # Water recycling is a sibling, not something embedded inside atmosphere.
      {LifeSupportSupervision.LifeSupportUnit, habitat_id: id, subsystem: :water},
      id: {LifeSupportSupervision.LifeSupportUnit, id, :water}
    ),
    Supervisor.child_spec(
      # Thermal control is also isolated so its crash does not take the others down.
      {LifeSupportSupervision.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
      id: {LifeSupportSupervision.LifeSupportUnit, id, :thermal}
    )
  ]

  # Restart only the child that crashed.
  Supervisor.init(children, strategy: :one_for_one)
end
```

The public API exposes the failure boundary directly:

```elixir
def subsystem_pid(habitat_id, subsystem) do
  case Registry.lookup(LifeSupportSupervision.Registry, {habitat_id, subsystem}) do
    [{pid, _value}] -> {:ok, pid}
    [] -> :error
  end
end

def induce_failure(habitat_id, subsystem) do
  with {:ok, pid} <- subsystem_pid(habitat_id, subsystem) do
    LifeSupportUnit.induce_failure(pid)
  end
end
```

That makes it easy to demonstrate that one failed subsystem restarts alone.

## Trying It Out

Run the lesson:

```bash
cd 04_life_support_supervision
mix test
```

You can also force a subsystem failure in `iex`:

```bash
cd 04_life_support_supervision
iex -S mix
```

Then:

```elixir
LifeSupportSupervision.start_habitat("hab-a")

{:ok, before_pid} =
  LifeSupportSupervision.subsystem_pid("hab-a", :thermal)

LifeSupportSupervision.induce_failure("hab-a", :thermal)
Process.sleep(50)

{:ok, after_pid} =
  LifeSupportSupervision.subsystem_pid("hab-a", :thermal)

before_pid != after_pid
```

You should see the crashed subsystem replaced while its siblings remain
available.

## What the Tests Prove

The test suite in
[`test/life_support_supervision_test.exs`](./test/life_support_supervision_test.exs)
proves three things:

- habitats can boot with multiple subsystem children
- a forced subsystem crash causes that child to restart
- sibling subsystems survive the failure

That last point is the real lesson. Restarting is easy. Restarting only the
right thing is the design problem.

## Why This Matters

This is the chapter where the colony starts to feel fault-tolerant instead of
merely concurrent.

The next pressure comes one level higher: once habitats have internal structure,
the whole colony also needs structure at the application root.

## OTP Takeaway

Supervision is about choosing the size of a failure.

OTP gives you restart behavior, but the real design work is deciding what should
count as a sibling and what should count as a dependent.

## What the Colony Can Do Now

The colony can now:

- start multiple habitats
- give each habitat its own supervised life-support services
- restart a failed subsystem in isolation
- preserve sibling uptime when one service falls over

That is the first real taste of auto-healing.

## What Still Hurts

The colony root is still too shapeless.

Habitats now have internal boundaries, but mission control, storage, and
communications still need a top-level structure of their own.

## Next Lesson

[`05_colony_control_tree`](../05_colony_control_tree/README.md) moves the same
supervision thinking up to the application root.
