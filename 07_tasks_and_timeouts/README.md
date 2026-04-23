# Lesson 07: The Colony Learns Which Work Should Stay Short

By lesson 6, the colony can run habitats, operations branches, and a dynamic
rover fleet. The next pressure point is computational work that does not deserve
its own permanent process.

Route planning is a good example. It matters, but it is bursty. The colony
wants the result, not a long-lived route planner that hangs around forever.
Some work should pass cleanly through the system instead of becoming an
institution.

## What You'll Learn

By the end of this lesson, you should understand:

- how to use `Task.Supervisor` for short-lived async work
- why some problems should stay tasks instead of servers
- how timeout boundaries make burst computation safer

## The Story

The colony now has three kinds of work:

- standing capability, like habitats and mission control
- temporary field workers, like rovers
- burst computation, like route planning

That third kind is different from both of the others.

Mars keeps forcing distinctions that softer worlds let people ignore. Some
things must endure. Some should arrive, return a result, and disappear.

When a rover needs a route, the colony wants to run the calculation, await the
answer, and move on. The route planner does not need a public identity or a
permanent mailbox.

## The OTP Concept

This chapter introduces `Task.Supervisor` for work that is:

- short-lived
- result-oriented
- better modeled as a computation than as a service

The key distinction is simple:

> some concurrency should leave behind a running process, and some should only
> leave behind a result.

## What This Chapter Adds

This lesson keeps the habitats, root tree, and rover fleet from lesson 6 and
adds:

- [`lib/tasks_and_timeouts/route_planner.ex`](./lib/tasks_and_timeouts/route_planner.ex)
- `Task.Supervisor` under the application tree
- public APIs to start and await route-planning tasks

## The Code

The lesson’s code lives in:

- [`lib/tasks_and_timeouts/route_planner.ex`](./lib/tasks_and_timeouts/route_planner.ex)
- [`lib/tasks_and_timeouts.ex`](./lib/tasks_and_timeouts.ex)
- [`test/tasks_and_timeouts_test.exs`](./test/tasks_and_timeouts_test.exs)

The route planner makes the distinction visible:

```elixir
def plan_route_async(route_request) do
  Task.Supervisor.async_nolink(TasksAndTimeouts.TaskSupervisor, fn ->
    # Simulate work that may take time without turning route planning
    # into a long-lived service.
    maybe_sleep(Map.get(route_request, :latency_ms, 0))

    %{
      origin: route_request.origin,
      destination: route_request.destination,
      hazard_window: route_request.hazard_window,
      status: :ready
    }
  end)
end

def await_plan(task, timeout) do
  # Let the caller choose how long it is willing to wait.
  Task.await(task, timeout)
end
```

The colony keeps the answer. It does not keep the worker.

The public API stays intentionally narrow:

```elixir
def plan_route_async(route_request), do: RoutePlanner.plan_route_async(route_request)
def await_plan(task, timeout), do: RoutePlanner.await_plan(task, timeout)
```

That is the whole design argument of the lesson. The runtime surface is about a
result, not about managing another named server forever.

## Trying It Out

Run the lesson:

```bash
cd 07_tasks_and_timeouts
mix test
```

You can also inspect one fast route plan in `iex`:

```bash
cd 07_tasks_and_timeouts
iex -S mix
```

Then:

```elixir
task =
  TasksAndTimeouts.plan_route_async(%{
    origin: "hab-a",
    destination: "ridge-12",
    hazard_window: "clear",
    latency_ms: 10
  })

TasksAndTimeouts.await_plan(task, 100)
```

You should see a route result without any long-lived route planner process left
behind.

## What the Tests Prove

The test suite in
[`test/tasks_and_timeouts_test.exs`](./test/tasks_and_timeouts_test.exs) proves
three things:

- route planning can run asynchronously under supervision
- successful work returns a route result
- slow work respects the timeout boundary and fails clearly

That timeout behavior is the real lesson. Concurrency is useful, but only when
the caller still has a clear contract.

## Why This Matters

The colony now knows three runtime shapes:

- long-lived services
- dynamic workers
- short-lived tasks

The next problem is communication. Once failures and warnings start moving
between all these pieces, direct point-to-point messages become too coupled.

## OTP Takeaway

Not every concurrent thing should become a server.

`Task.Supervisor` is OTP’s way of saying, “run this safely, then let it go.”

## What the Colony Can Do Now

The colony can now:

- run standing services for core infrastructure
- launch temporary workers for surface missions
- execute burst computation under supervision with an explicit timeout

The runtime is starting to distinguish between kinds of work, not just kinds of
modules.

## What Still Hurts

Warnings still spread too directly.

As soon as pressure drops in a habitat or a rover reports distress, multiple
parts of the colony need to know. Wiring those paths one process at a time will
become brittle fast.

## Next Lesson

[`08_pubsub_alerts`](../08_pubsub_alerts/README.md) introduces a local pubsub
pattern for alert fan-out.
