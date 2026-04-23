# mars_colony_otp

`mars_colony_otp` teaches OTP by following the slow hardening of a Mars colony.

The series begins with one raw habitat process loop and one habitat that barely
knows how to keep a clean ledger.
It ends with a supervised colony that can launch rovers, fan out alerts, absorb
load, process telemetry, coordinate incidents, carry selected operational
memory across restarts, and reach a remote outpost node.

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

This repo is trying to teach that pressure, not just the APIs.

## The Journey

Lesson `00` is the manual-process prelude. Lessons `01` through `15` then grow
the colony cumulatively:

0. [`00_process_loop`](./00_process_loop/README.md)
   One habitat is implemented as a raw mailbox loop so the reader can see the manual process model beneath OTP.
1. [`01_habitat_bootstrap`](./01_habitat_bootstrap/README.md)
   One habitat learns to track oxygen, water, power, crew, and maintenance through pure state transitions.
2. [`02_habitat_server`](./02_habitat_server/README.md)
   That same habitat goes live as a `GenServer`.
3. [`03_named_habitats`](./03_named_habitats/README.md)
   The colony grows beyond one habitat and learns runtime identity with `Registry`.
4. [`04_life_support_supervision`](./04_life_support_supervision/README.md)
   Each habitat becomes a small supervision tree with restartable subsystems.
5. [`05_colony_control_tree`](./05_colony_control_tree/README.md)
   The colony adds top-level branches for operations, communications, and habitat fleet ownership.
6. [`06_dynamic_rovers`](./06_dynamic_rovers/README.md)
   Surface work becomes dynamic, so rovers are created and retired at runtime.
7. [`07_tasks_and_timeouts`](./07_tasks_and_timeouts/README.md)
   Not every unit of work deserves a permanent process, so route planning moves into supervised tasks.
8. [`08_pubsub_alerts`](./08_pubsub_alerts/README.md)
   Alerts start spreading across the runtime without direct process-to-process coupling.
9. [`09_backpressure_and_queues`](./09_backpressure_and_queues/README.md)
   Maintenance intake gets explicit queue ownership and overload signaling.
10. [`10_telemetry_and_observability`](./10_telemetry_and_observability/README.md)
    Queue behavior becomes observable with `:telemetry`.
11. [`11_genstage_resource_pipeline`](./11_genstage_resource_pipeline/README.md)
    Sensor packets turn into a demand-driven stream with `GenStage`.
12. [`12_broadway_anomaly_response`](./12_broadway_anomaly_response/README.md)
    The anomaly path matures into a Broadway pipeline.
13. [`13_incident_commander`](./13_incident_commander/README.md)
    Alerts become coordinated response instead of isolated messages.
14. [`14_persistent_shift_handoff`](./14_persistent_shift_handoff/README.md)
    The colony learns how to persist selected operational memory across restarts.
15. [`15_distributed_outposts`](./15_distributed_outposts/README.md)
    Mission control reaches a remote outpost node and learns the first practical distributed Elixir tools.

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
anomalies, and far-future origin inquiry stories take shape.

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
helps to see the raw shape of one mailbox-driven process.
