# Lesson 09: Maintenance Starts Backing Up

By lesson 8, the colony can spread alerts across the runtime. That makes the
system better informed, but it also makes pressure more visible. Work begins to
pile up.

Maintenance requests are the first clear example. They arrive over time, they
need to be buffered, and the colony needs to know when the queue is becoming a
problem. Not every form of pressure announces itself with alarms. Some of it
gathers in lists, delays, and the slow embarrassment of unfinished work.

## What You'll Learn

By the end of this lesson, you should understand:

- how a `GenServer` can own a queue explicitly
- why queue ownership is different from “just keeping a list somewhere”
- how overload signaling creates a visible backpressure boundary

## The Story

The colony is now noisy enough that maintenance cannot stay informal.

Every new system the colony gains gives it one more way to endure and one more
way to break. Seals age. Filters clog. Rover joints grind red dust into their
own patience. The work begins to stack up not because anyone is careless, but
because survival on Mars is made of wearing things out.

Backlog is what the future looks like when obligations arrive faster than
strength, and making that visible is one of the colony's first real acts of
honesty about its own limits.

Requests arrive from many directions:

- habitat service issues
- rover repairs
- storage faults
- relay equipment wear

At first, a queue looks like a list. In practice, it becomes a contract:

- who accepts the request
- who decides when the queue is too deep
- who tracks what is queued versus in flight

That ownership is what this lesson adds.

## The OTP Concept

This chapter uses a `GenServer` again, but for a different reason than lesson 2.

This is not “one server that owns one domain object.”

This is:

> one process that owns a flow-control boundary.

The queue process exists so the colony has one authoritative answer to “how much
work is waiting?” and “are we overloaded yet?”

## What This Chapter Adds

This lesson keeps habitats, top-level branches, rovers, tasks, and alert fan-out
from lesson 8 and adds:

- [`lib/backpressure_and_queues/maintenance_queue.ex`](./lib/backpressure_and_queues/maintenance_queue.ex)
- queue APIs for enqueue, dispatch, ack, and snapshot
- overload signaling when the queue exceeds a configured depth

## The Code

The lesson’s code lives in:

- [`lib/backpressure_and_queues/maintenance_queue.ex`](./lib/backpressure_and_queues/maintenance_queue.ex)
- [`lib/backpressure_and_queues.ex`](./lib/backpressure_and_queues.ex)
- [`test/backpressure_and_queues_test.exs`](./test/backpressure_and_queues_test.exs)

The queue process owns both buffered work and in-flight work:

```elixir
@impl true
def init(opts) do
  {:ok,
   %{
     # Buffered requests waiting to be dispatched.
     queue: :queue.new(),
     # Requests already handed out to workers but not yet acknowledged.
     inflight: %{},
     # Depth at which callers should consider the system overloaded.
     max_queue: Keyword.get(opts, :max_queue, 3)
   }}
end
```

The enqueue path makes backpressure visible instead of implicit:

```elixir
def handle_call({:enqueue, request}, _from, state) do
  next_queue = :queue.in(request, state.queue)
  next_state = %{state | queue: next_queue}

  # Overload is a first-class runtime signal, not a guess made elsewhere.
  overloaded = :queue.len(next_queue) > state.max_queue

  {:reply, {:ok, overloaded}, next_state}
end
```

And the dispatch path makes ownership concrete:

```elixir
def handle_call(:dispatch_next, _from, state) do
  case :queue.out(state.queue) do
    {{:value, request}, rest} ->
      next_state = %{
        state
        | queue: rest,
          inflight: Map.put(state.inflight, request.id, request)
      }

      {:reply, {:ok, request}, next_state}

    {:empty, _queue} ->
      {:reply, :empty, state}
  end
end
```

That gives the colony one clear owner for queued and active maintenance work.

## Trying It Out

Run the lesson:

```bash
cd 09_backpressure_and_queues
mix test
```

You can also inspect the queue in `iex`:

```bash
cd 09_backpressure_and_queues
iex -S mix
```

Then:

```elixir
BackpressureAndQueues.enqueue_request(%{id: "m-1", system: :water, action: "replace seal"})
BackpressureAndQueues.enqueue_request(%{id: "m-2", system: :thermal, action: "inspect valve"})

BackpressureAndQueues.dispatch_next()
BackpressureAndQueues.snapshot()
```

You should see the queue shrink while the dispatched request moves into the
`inflight` map.

## What the Tests Prove

The test suite in
[`test/backpressure_and_queues_test.exs`](./test/backpressure_and_queues_test.exs)
proves three things:

- requests are buffered in arrival order
- dispatched work moves from the queue into the in-flight set
- callers get an overload signal when the queue exceeds its configured depth

That last point is the real lesson. Backpressure only matters if the system can
say when it is under pressure.

## Why This Matters

The colony now has a real intake surface for maintenance work.

The next question is observability. Once queue depth and dispatch timing become
important, operators need a way to measure that behavior without reaching inside
the process manually.

## OTP Takeaway

A queue is not just a data structure. In a running system, it is a boundary of
ownership and pressure.

## What the Colony Can Do Now

The colony can now:

- accept maintenance work through one process
- expose queued versus in-flight work clearly
- dispatch and acknowledge requests explicitly
- signal overload when intake depth gets too high

The runtime has started to admit that work can outrun capacity.

## What Still Hurts

The queue can tell us it is overloaded, but the colony still has to ask by hand.
The system needs a way to emit measurements as it operates.

## Next Lesson

[`10_telemetry_and_observability`](../10_telemetry_and_observability/README.md)
adds `:telemetry` on top of the maintenance queue.
