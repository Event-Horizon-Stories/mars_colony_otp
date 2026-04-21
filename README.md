# mars_colony_otp

`mars_colony_otp` teaches OTP by following the slow hardening of a Mars colony.

The series begins with one habitat's resource ledger and gradually adds long-lived
processes, naming, supervision, dynamic workers, alerting, telemetry, streaming,
and recovery. Each lesson is its own standalone Mix project, but together they
follow the same colony as it becomes operationally credible.

The point is not to throw OTP concepts at the reader in isolation. The point is
to let the colony grow in believable steps so each chapter earns the abstraction
it introduces.

## The Journey

1. [`01_habitat_bootstrap`](./01_habitat_bootstrap/README.md)
   Pure state transitions for one habitat's oxygen, water, power, and maintenance plan.
2. [`02_habitat_server`](./02_habitat_server/README.md)
   A single habitat becomes a live `GenServer`.
3. [`03_named_habitats`](./03_named_habitats/README.md)
   Multiple habitats are addressed by ID through a `Registry`.
4. [`04_life_support_supervision`](./04_life_support_supervision/README.md)
   Atmosphere, water, and thermal services run under a habitat supervision tree.
5. [`05_colony_control_tree`](./05_colony_control_tree/README.md)
   The colony is organized into top-level supervised branches.
6. [`06_dynamic_rovers`](./06_dynamic_rovers/README.md)
   Rovers are launched on demand through a `DynamicSupervisor`.
7. [`07_tasks_and_timeouts`](./07_tasks_and_timeouts/README.md)
   Burst work such as route planning runs under `Task.Supervisor`.
8. [`08_pubsub_alerts`](./08_pubsub_alerts/README.md)
   Alerts fan out to decoupled subscribers through a local event bus.
9. [`09_backpressure_and_queues`](./09_backpressure_and_queues/README.md)
   Maintenance requests are buffered and drained with explicit queue ownership.
10. [`10_telemetry_and_observability`](./10_telemetry_and_observability/README.md)
    The runtime starts emitting measurements the operators can reason about.
11. [`11_genstage_resource_pipeline`](./11_genstage_resource_pipeline/README.md)
    Habitat and rover sensors flow through a demand-driven `GenStage` pipeline.
12. [`12_broadway_anomaly_response`](./12_broadway_anomaly_response/README.md)
    Telemetry handling graduates to a Broadway pipeline for batched anomaly work.
13. [`13_incident_commander`](./13_incident_commander/README.md)
    A coordinator process turns alerts into multi-system response actions.
14. [`14_persistent_shift_handoff`](./14_persistent_shift_handoff/README.md)
    Selected operational state survives restarts so the next shift inherits context.

## Final Colony Shape

By the end of the series, the runtime looks roughly like this:

```text
ColonySupervisor
|- MissionControlSupervisor
|  |- IncidentCommander
|  `- AlertBus
|- HabitatFleetSupervisor
|  `- HabitatSupervisor (per habitat)
|     |- AtmosphereControl
|     |- WaterRecycler
|     `- ThermalControl
|- RoverSupervisor
|  `- RoverServer (per rover)
|- MaintenanceQueue
`- TelemetryPipelines
   |- GenStage sensor flow
   `- Broadway anomaly flow
```

## Start Here

Begin with [`01_habitat_bootstrap`](./01_habitat_bootstrap/README.md).

Before the colony gets processes, it first needs state transitions that are easy
to read, test, and trust.
