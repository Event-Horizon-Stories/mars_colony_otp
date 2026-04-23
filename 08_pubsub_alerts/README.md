# Lesson 08: Alerts Start Moving Faster Than People

By lesson 7, the colony has habitats, a root tree, dynamic rovers, and
short-lived tasks for burst computation. The next pressure point is
communication.

Warnings and incidents no longer belong to one caller. If a habitat drops below
safe pressure or a rover reports distress, multiple parts of the colony may
need to know about it at once.

## What You'll Learn

By the end of this lesson, you should understand:

- how to build a local pubsub-style alert surface with `Registry`
- why fan-out is less coupled than direct point-to-point messaging
- how a cumulative system can add broadcast behavior without rewriting its
  earlier APIs

## The Story

The colony has grown into a place where one warning can matter to many people.

In the early days, a problem could stay inside one room for a little while.
That mercy is gone now. Trouble in one habitat can bend the whole day's work.
A distress call from the surface can reach engineering, medicine, and command
before anyone has time to decide how frightened to be.

An alert is never only information. It changes the emotional weather of the
colony.

One warning can matter to many people:

- mission control wants situational awareness
- engineering wants the technical signal
- medical may care if a habitat condition becomes dangerous
- field teams may need to reroute immediately

Directly wiring every producer to every consumer would make the colony brittle.
The runtime needs a shared alert surface instead.

## The OTP Concept

This chapter introduces a local publish-subscribe pattern for one reason:

> alerts should fan out by topic, not by hard-coded knowledge of every listener.

This is not about introducing a heavy event platform. It is about giving the
runtime a decoupled way to spread operational signals.

## What This Chapter Adds

This lesson keeps the habitats, colony root, rover fleet, and task-based route
planning from lesson 7 and adds:

- an alert registry for duplicate topic subscriptions
- `subscribe/1` and `publish/2` APIs
- a runtime surface for colony-wide alert fan-out

## The Code

The lesson’s code lives in:

- [`lib/pubsub_alerts.ex`](./lib/pubsub_alerts.ex)
- [`lib/pubsub_alerts/application.ex`](./lib/pubsub_alerts/application.ex)
- [`test/pubsub_alerts_test.exs`](./test/pubsub_alerts_test.exs)

The public API is intentionally tiny:

```elixir
def subscribe(topic) when is_atom(topic) do
  # Register the current process under a topic such as :critical_alerts.
  Registry.register(PubsubAlerts.AlertRegistry, topic, [])
end

def publish(topic, payload) when is_atom(topic) do
  Registry.dispatch(PubsubAlerts.AlertRegistry, topic, fn entries ->
    for {pid, _meta} <- entries do
      # Fan the same alert out to every interested subscriber.
      send(pid, {:colony_alert, topic, payload})
    end
  end)
end
```

That is the new communication surface.

The rest of the public API makes the cumulative design visible. The chapter did
not lose habitats, rovers, or tasks when alerts arrived:

```elixir
def launch_rover(id, opts \\ []), do: RoverSupervisor.launch_rover(id, opts)

def plan_route_async(route_request), do: RoutePlanner.plan_route_async(route_request)
def await_plan(task, timeout), do: RoutePlanner.await_plan(task, timeout)
```

The alert system is a new layer on top of an already coherent colony, not a
replacement for what came before.

## Trying It Out

Run the lesson:

```bash
cd 08_pubsub_alerts
mix test
```

You can also watch one process subscribe and receive an alert in `iex`:

```bash
cd 08_pubsub_alerts
iex -S mix
```

Then:

```elixir
PubsubAlerts.subscribe(:critical_alerts)

PubsubAlerts.publish(:critical_alerts, %{
  habitat: "hab-a",
  system: :atmosphere,
  severity: :critical
})

flush()
```

You should see the alert delivered to the subscribing process without the
publisher knowing anything about that process directly.

## What the Tests Prove

The test suite in [`test/pubsub_alerts_test.exs`](./test/pubsub_alerts_test.exs)
proves two things:

- multiple subscribers can receive the same alert topic
- the rest of the colony runtime still works while alert fan-out is added on top

That second point matters because communication patterns should extend a system,
not force a rewrite of it.

## Why This Matters

The colony can now spread warnings without hard-coding every listener.

That solves communication coupling, but it exposes a new operational problem:
work starts to pile up. Once alerts and requests are flowing, maintenance intake
needs its own explicit owner.

## OTP Takeaway

Fan-out is a runtime concern of its own.

Sometimes the right abstraction is not another worker. It is a shared signal
surface that lets workers remain ignorant of each other.

## What the Colony Can Do Now

The colony can now:

- run habitats, rovers, and route-planning tasks
- subscribe listeners to alert topics
- fan one alert out to many processes
- keep producers decoupled from consumers

The colony now has something like a nervous system.

## What Still Hurts

The nervous system can spread warnings, but the workload itself still lacks a
single owner. Maintenance requests can pile up faster than anyone handles them.

## Next Lesson

[`09_backpressure_and_queues`](../09_backpressure_and_queues/README.md) gives
maintenance intake its own queue and overload semantics.
