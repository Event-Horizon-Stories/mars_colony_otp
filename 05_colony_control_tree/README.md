# Lesson 05: Mission Control Gets a Real Tree

This chapter lifts supervision one level higher.

Lesson 4 gave each habitat its own internal tree. Now the application itself
needs a shape that reflects domain boundaries: operations, communications, and
the habitat fleet should not all be a flat list of children. The settlement is
no longer a cluster of rooms. It is beginning to resemble a civilization in
miniature. Civilization, even in its smallest form, is mostly the problem of
placing responsibility where it can be found again under pressure.

## What You'll Learn

By the end of this lesson, you should understand:

- how to compose nested supervision trees at the application root
- why top-level branches should usually follow domain ownership
- how a root tree makes a growing system easier to reason about

## The Story

The colony has outgrown the feeling of “some habitats plus a few helpers.”

By now there are enough moving parts that someone has to watch the habitats,
someone has to watch storage, and someone has to keep the signal line alive.

Hierarchy here is the visible shape of responsibility.

There are now distinct operational domains:

- mission control
- storage
- communications relay
- habitat fleet management

Those systems do not all belong in one flat pile. The runtime should reflect
the way the colony is actually operated.

## The OTP Concept

This chapter is still about supervision, but at a different level:

> not just what fails together inside a service, but what belongs together at
> the top of the application.

A root supervision tree is an architectural map.

## What We're Building

This chapter keeps the full habitat fleet from lesson 4 and adds:

- [`lib/colony_control_tree/application.ex`](./lib/colony_control_tree/application.ex)
- [`lib/colony_control_tree/branch_supervisors.ex`](./lib/colony_control_tree/branch_supervisors.ex)
- [`lib/colony_control_tree/domain_service.ex`](./lib/colony_control_tree/domain_service.ex)

We are not replacing habitats. We are placing them alongside the rest of the
colony under a clearer root.

## The Code

The lesson’s code lives in:

- [`lib/colony_control_tree/application.ex`](./lib/colony_control_tree/application.ex)
- [`lib/colony_control_tree.ex`](./lib/colony_control_tree.ex)
- [`lib/colony_control_tree/domain_service.ex`](./lib/colony_control_tree/domain_service.ex)
- [`test/colony_control_tree_test.exs`](./test/colony_control_tree_test.exs)

The application root now spells out the major colony branches:

```elixir
@impl true
def start(_type, _args) do
  children = [
    # One shared registry for looking up both top-level services and habitat subsystems.
    {Registry, keys: :unique, name: ColonyControlTree.Registry},

    # The habitat fleet from lesson 4 stays exactly where it belongs: as one domain branch.
    {ColonyControlTree.HabitatFleet, []},

    # Operations owns mission control and storage.
    {ColonyControlTree.OperationsSupervisor, []},

    # Communications owns the colony relay surface.
    {ColonyControlTree.CommunicationsSupervisor, []}
  ]

  opts = [strategy: :one_for_one, name: ColonyControlTree.Supervisor]
  Supervisor.start_link(children, opts)
end
```

The public API shows that the lesson is cumulative. It still knows how to work
with habitats while adding top-level services:

```elixir
def start_habitat(id), do: HabitatFleet.start_habitat(id)

def service_pid(service) do
  case Registry.lookup(ColonyControlTree.Registry, service) do
    # Named services like :mission_control can now be found from the root tree.
    [{pid, _value}] -> {:ok, pid}
    [] -> :error
  end
end

def subsystem_pid(habitat_id, subsystem) do
  case Registry.lookup(ColonyControlTree.Registry, {habitat_id, subsystem}) do
    # Habitat subsystems are still first-class citizens in the same registry.
    [{pid, _value}] -> {:ok, pid}
    [] -> :error
  end
end
```

That is the lesson 5 move. The runtime starts to look like the colony it is
trying to represent.

## Trying It Out

Run the lesson:

```bash
cd 05_colony_control_tree
mix test
```

You can also inspect the top-level services in `iex`:

```bash
cd 05_colony_control_tree
iex -S mix
```

Then:

```elixir
{:ok, _pid} = ColonyControlTree.start_habitat("hab-a")

ColonyControlTree.service_pid(:mission_control)
ColonyControlTree.service_pid(:storage)
ColonyControlTree.service_pid(:comms_relay)
ColonyControlTree.subsystem_pid("hab-a", :water)
```

You should be able to see both the colony branches and the inherited habitat
subsystems living in the same root tree.

## What the Tests Prove

The test suite in
[`test/colony_control_tree_test.exs`](./test/colony_control_tree_test.exs)
proves three things:

- the colony boots with distinct operational branches
- domain services can be found through the registry
- habitats still behave correctly inside the larger tree

That continuity matters because the lesson is cumulative. The new root does not
replace habitats. It gives them a clearer neighborhood.

## Why This Matters

Once the root tree has a real shape, the colony can start creating workers whose
lifetime is driven by demand instead of boot time.

That is the next jump.

## OTP Takeaway

The application root is not just startup code.

It is the place where the system declares its major domains and their ownership
boundaries.

## What the Colony Can Do Now

The colony can now:

- boot a habitat fleet under the root supervisor
- separate operations from communications
- register top-level services by intent
- preserve the lesson 4 failure boundaries inside a larger structure

The colony finally has a real spine.

## What Still Hurts

Everything under the root still starts because the application starts.

That is right for mission control. It is wrong for surface work that appears and
disappears with the day’s missions.

## Next Lesson

[`06_dynamic_rovers`](../06_dynamic_rovers/README.md) introduces rovers as
runtime-created workers under a `DynamicSupervisor`.
