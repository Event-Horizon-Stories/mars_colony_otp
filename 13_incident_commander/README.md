# Lesson 13: The Colony Learns to Command an Incident

The colony can move from sensor packets to anomaly batches. The next pressure
point is no longer detection. It is response.

When something critical happens, the colony needs one place to own the incident
state, decide what action to take, and leave behind an inspectable record of
the response. Emergency has a way of scattering attention, so this chapter
gives the runtime one accountable place to gather it back together.

## What You'll Learn

By the end of this lesson, you should understand:

- how to model incident coordination as a long-lived process
- why orchestration state should be explicit instead of spread across handlers
- how a process can subscribe to alerts and trigger downstream work

## The Story

The colony has reached the point where critical alerts mean more than “someone
should know.”

There is a moment in every emergency when information stops being enough. The
settlement needs judgment, sequence, and memory held together under pressure. A
bad decision can be revised later. A scattered decision can leave no single
shape behind, and that is worse.

The system needs somewhere to stand when everything around it begins moving at
once.

A serious failure now implies coordination:

- record the incident
- decide on an operational response
- enqueue repair work
- leave behind a response trail that can be inspected later

That makes incident command its own runtime responsibility.

## The OTP Concept

This chapter is about orchestration.

Not orchestration in the abstract sense of “many things happen,” but in the
practical OTP sense of:

> one process should own the evolving state of a response plan.

If incident state is spread across random subscribers, the colony may still
react, but it will be hard to inspect and harder to trust.

## What This Chapter Adds

This lesson keeps the entire colony from lesson 12 and adds:

- `IncidentCommander.AlertBus`
- `IncidentCommander.Commander`
- public APIs to publish critical alerts and inspect active incidents

## The Code

The lesson’s code lives in:

- [`lib/incident_commander/commander.ex`](./lib/incident_commander/commander.ex)
- [`lib/incident_commander.ex`](./lib/incident_commander.ex)
- [`test/incident_commander_test.exs`](./test/incident_commander_test.exs)

The commander subscribes itself when it boots:

```elixir
@impl true
def init(_opts) do
  # Delay subscription until after init so startup stays simple.
  send(self(), :subscribe)
  {:ok, %{active_incidents: [], response_log: []}}
end

@impl true
def handle_info(:subscribe, state) do
  IncidentCommander.AlertBus.subscribe(:critical_alerts)
  {:noreply, state}
end
```

That gives the process a stable place in the runtime to hear about critical
events.

The actual orchestration logic stays explicit:

```elixir
def handle_info({:incident_alert, :critical_alerts, alert}, state) do
  action = %{id: "repair-#{alert.system}", system: alert.system, action: "dispatch repair crew"}
  :ok = IncidentCommander.MaintenanceQueue.enqueue(action)

  next_state = %{
    state
    # Keep a visible list of active incidents.
    | active_incidents: state.active_incidents ++ [alert],
      # Keep a human-readable response trail for operators.
      response_log: state.response_log ++ ["reroute load and dispatch #{alert.system} repair"]
  }

  {:noreply, next_state}
end
```

That is the chapter’s key move. The colony does not just hear an alert. It folds
that alert into a persistent response state and triggers repair work.

The top-level API makes the orchestration surface easy to use:

```elixir
def report_alert(alert) do
  IncidentCommander.AlertBus.publish(:critical_alerts, alert)
end

def incident_snapshot, do: Commander.snapshot()

def queue_snapshot do
  MaintenanceQueue.snapshot().queued
end
```

## Trying It Out

Run the lesson:

```bash
cd 13_incident_commander
mix test
```

You can also trigger one incident in `iex`:

```bash
cd 13_incident_commander
iex -S mix
```

Then:

```elixir
IncidentCommander.report_alert(%{
  habitat: "hab-a",
  system: :thermal,
  severity: :critical
})

Process.sleep(50)

IncidentCommander.incident_snapshot()
IncidentCommander.queue_snapshot()
```

You should see the alert recorded as an active incident and a repair action
queued in response.

## What the Tests Prove

The test suite in
[`test/incident_commander_test.exs`](./test/incident_commander_test.exs) proves
that:

- the commander subscribes to critical alerts
- a critical alert becomes incident state
- the commander enqueues repair work as part of the response

That middle point is the real lesson. The system now has one explicit owner for
the evolving response plan.

## Why This Matters

The colony can now detect, classify, and respond.

The final missing piece is memory. Once the shift ends or the app restarts, the
colony should not lose every operational summary it just learned.

## OTP Takeaway

Orchestration becomes safer when one process owns the response state and exposes
that state for inspection.

## What the Colony Can Do Now

The colony can now:

- keep the earlier habitat, rover, queue, and pipeline machinery
- receive critical alerts through a shared alert surface
- turn those alerts into explicit incident state
- queue repair work as part of one orchestrated response path

The colony finally has someone clearly in charge when things go wrong.

## What Still Hurts

The commander can own the live response, but selected operational memory still
dies with the process. Shift handoff is still too fragile.

## Next Lesson

[`14_persistent_shift_handoff`](../14_persistent_shift_handoff/README.md) adds a
small persistence boundary for handoff summaries.
