# mars_colony_otp

`mars_colony_otp` teaches OTP through the slow hardening of a Mars colony.

The series begins with one raw habitat process loop and one habitat that barely
knows how to keep a clean ledger. The walls are thin, the air is borrowed, and
every ordinary routine is one more argument against the surrounding silence. It
ends with a supervised colony that can launch rovers, fan out alerts, absorb
load, process telemetry, coordinate incidents, carry selected operational
memory across restarts, and reach a remote outpost node without pretending the
planet has grown smaller.

A colony begins not when people arrive, but when they learn which fragilities
must be named before hope can last, which is why this story starts close to the
walls before it ever looks toward the wider sky.

Each chapter is its own standalone Mix project.

Lesson `00` is a prelude that shows the raw mailbox loop underneath OTP. From
lesson `01` onward, the story becomes cumulative. Later lessons do not throw
earlier ones away. They inherit the colony that came before and extend it.

That matters because OTP is easiest to learn when the abstractions arrive under
pressure:

- a pure module becomes a `GenServer` when state needs to live
- a single service gets a `Registry` when one instance becomes many
- a worker gets a supervisor when failure must stay local
- a queue appears when work starts piling up
- a pipeline appears when events stop looking like isolated messages

Mars does not forgive vague ownership. A missing boundary becomes a leak. An
unnamed process becomes a room nobody reaches in time. A silent queue becomes a
future problem already underway.

## The Journey

Lesson `00` is the manual-process prelude. Lessons `01` through `15` then grow
the colony cumulatively:

0. [`00_process_loop`](./00_process_loop/README.md)
   One transit habitat survives on a raw mailbox loop while the colony is still only a promise in flight.
1. [`01_habitat_bootstrap`](./01_habitat_bootstrap/README.md)
   The first habitat learns to account for oxygen, water, power, crew, and maintenance through pure state transitions.
2. [`02_habitat_server`](./02_habitat_server/README.md)
   That same habitat stops living in a notebook and begins answering as a `GenServer`.
3. [`03_named_habitats`](./03_named_habitats/README.md)
   The settlement spreads beyond one room and learns runtime identity with `Registry`.
4. [`04_life_support_supervision`](./04_life_support_supervision/README.md)
   Each habitat grows an inner skeleton of restartable subsystems.
5. [`05_colony_control_tree`](./05_colony_control_tree/README.md)
   Mission control, communications, storage, and the habitat fleet take their places in the root tree.
6. [`06_dynamic_rovers`](./06_dynamic_rovers/README.md)
   Surface work starts arriving with the Martian day, so rovers are born and retired at runtime.
7. [`07_tasks_and_timeouts`](./07_tasks_and_timeouts/README.md)
   The colony learns that not every hard calculation deserves a permanent process, so route planning moves into supervised tasks.
8. [`08_pubsub_alerts`](./08_pubsub_alerts/README.md)
   Warnings begin to outrun individual callers and spread across the runtime without direct coupling.
9. [`09_backpressure_and_queues`](./09_backpressure_and_queues/README.md)
   Maintenance backlog becomes visible pressure with explicit queue ownership and overload signaling.
10. [`10_telemetry_and_observability`](./10_telemetry_and_observability/README.md)
    The colony starts narrating its own strain through `:telemetry`.
11. [`11_genstage_resource_pipeline`](./11_genstage_resource_pipeline/README.md)
    Sensor traffic stops behaving like isolated messages and becomes a demand-driven stream with `GenStage`.
12. [`12_broadway_anomaly_response`](./12_broadway_anomaly_response/README.md)
    The anomaly path grows from a lesson pipeline into a Broadway-shaped operational surface.
13. [`13_incident_commander`](./13_incident_commander/README.md)
    Alerts become coordinated response, owned by a process that can still be questioned after the dust settles.
14. [`14_persistent_shift_handoff`](./14_persistent_shift_handoff/README.md)
    The colony learns how to preserve selected memory across restarts and between crews.
15. [`15_distributed_outposts`](./15_distributed_outposts/README.md)
    Mission control reaches across the planet to a remote outpost node and meets the first practical distributed Elixir tools.

## Final Colony Shape

By the end of the tutorial, the runtime looks roughly like this:

```text
MissionControlNode
`- DistributedOutposts.Application
   |- Registry
   |- AlertRegistry
   |- HabitatFleet
   |  `- HabitatSupervisor (per habitat)
   |     |- LifeSupportUnit (:atmosphere)
   |     |- LifeSupportUnit (:water)
   |     `- LifeSupportUnit (:thermal)
   |- OperationsSupervisor
   |  |- DomainService (:mission_control)
   |  `- DomainService (:storage)
   |- CommunicationsSupervisor
   |  `- DomainService (:comms_relay)
   |- RoverSupervisor
   |  `- Rover (per mission)
   |- TaskSupervisor
   |- MaintenanceQueue
   |- Commander
   `- OutpostBeacon

RemoteOutpostNode
`- DistributedOutposts.Application
   |- Registry
   |- AlertRegistry
   |- HabitatFleet
   |- OperationsSupervisor
   |- CommunicationsSupervisor
   |- RoverSupervisor
   |- TaskSupervisor
   |- MaintenanceQueue
   |- Commander
   `- OutpostBeacon
```

That tree is intentionally small. It is enough to show the OTP ideas without
turning the tutorial into infrastructure sprawl.

In lesson 15, mission control mainly queries the remote habitat, queue,
commander, and beacon even though the remote node boots the same broader
application tree.

Some lesson-specific processes are started on demand rather than at boot. In the
later chapters, the handoff log needs a path before it can start, and the
sensor/Broadway pipelines are brought up explicitly by the public APIs when the
reader wants to explore those data paths.

## What You Will Learn Across The Series

The full arc covers the core OTP ladder most readers actually need:

- raw `spawn_link` / `send` / `receive` loops before `GenServer`
- pure state transitions before processes
- `GenServer`
- `Registry`
- `Supervisor`
- `DynamicSupervisor`
- `Task.Supervisor`
- local pubsub patterns
- queue ownership and backpressure
- `:telemetry`
- `GenStage`
- Broadway
- orchestration with explicit runtime state
- selective persistence
- first distributed Elixir patterns with `Node`, `:rpc`, and `:global`

## Using The Lessons

Each chapter owns its own code, tests, and dependencies.

Run a chapter from inside its directory:

```bash
cd 06_dynamic_rovers
mix test
```

If you want to inspect a chapter live:

```bash
cd 06_dynamic_rovers
iex -S mix
```

Every lesson includes `:observer` in `extra_applications`, so `:observer.start()`
is available while you explore the running system.

## Timeline

`mars_colony_otp` sits at the beginning of the shared story timeline.

It covers the first durable colony runtime on Mars, before the later fleet
autonomy, interplanetary signal, dispatch, trade bureaucracy, temporal
anomalies, and far-future origin inquiry stories take shape. This is the era
when the edge of the known world is still only one planet away, and still wide
enough to make every light in a habitat feel temporary against the dark.

The farther the later stories travel, the more they inherit the lesson born
here: the universe first becomes vast when a single room realizes how much
depends on one more hour of order.

## Related Stories

- Next fleet era: [`helios_fleet`](https://github.com/Event-Horizon-Stories/helios_fleet)
- Next network era: [`signal_network`](https://github.com/Event-Horizon-Stories/signal_network)
- Later dispatch era: [`orbital_dispatch`](https://github.com/Event-Horizon-Stories/orbital_dispatch)
- Later institutions: [`galactic_trade_authority`](https://github.com/Event-Horizon-Stories/galactic_trade_authority)
- Later temporal crisis: [`wormhole_protocol`](https://github.com/Event-Horizon-Stories/wormhole_protocol)
- Far-future inquiry: [`horizon_engine`](https://github.com/Event-Horizon-Stories/horizon_engine)

## Start Here

Begin with [`00_process_loop`](./00_process_loop/README.md).

Before the colony gets a supervisor, a registry, or a streaming pipeline, it
helps to see the raw shape of one mailbox-driven process and one fragile system
learning what survival will cost.
