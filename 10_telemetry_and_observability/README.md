# Lesson 10: The Colony Starts Talking About Itself

Lesson 9 gave maintenance work a real queue. That made pressure explicit, but
only to code that calls the queue directly. Operators still need visibility.

This chapter adds instrumentation so the colony can emit measurements while it
works instead of forcing every observer to poll internal state manually.

## What You'll Learn

By the end of this lesson, you should understand:

- how to use `:telemetry` as an instrumentation surface
- why measurements and metadata should be emitted at meaningful runtime
  boundaries
- how observability can layer on top of existing behavior without changing the
  core contract

## The Story

The maintenance queue has become important enough to measure.

Operators want to know:

- how deep the queue is getting
- when work is dispatched
- which requests triggered overload conditions

The queue still owns the truth. Telemetry simply lets the runtime publish useful
facts about that truth as it changes.

## The OTP Concept

This chapter introduces `:telemetry` for one reason:

> once a runtime behavior matters operationally, it should have an event surface.

Telemetry is not a replacement for state. It is a way to expose meaningful
moments without teaching every caller how to inspect every process.

## What This Chapter Adds

This lesson keeps the full colony from lesson 9 and upgrades the maintenance
queue with:

- `:telemetry.execute/3` on enqueue
- `:telemetry.execute/3` on dispatch
- queue depth measurements and request metadata

## The Code

The lesson’s code lives in:

- [`lib/telemetry_and_observability/maintenance_queue.ex`](./lib/telemetry_and_observability/maintenance_queue.ex)
- [`lib/telemetry_and_observability.ex`](./lib/telemetry_and_observability.ex)
- [`test/telemetry_and_observability_test.exs`](./test/telemetry_and_observability_test.exs)

The queue contract stays familiar, but now meaningful events are emitted as the
work happens:

```elixir
def handle_call({:enqueue, request}, _from, state) do
  next_queue = :queue.in(request, state.queue)
  next_state = %{state | queue: next_queue}
  overloaded = :queue.len(next_queue) > state.max_queue

  :telemetry.execute(
    [:mars_colony, :maintenance_queue, :enqueue],
    # Measurements answer "how much?".
    %{queue_depth: :queue.len(next_queue)},
    # Metadata answers "which request?" and "was this overloaded?".
    %{request_id: request.id, overloaded?: overloaded}
  )

  {:reply, :ok, next_state}
end
```

Dispatch gets the same treatment:

```elixir
def handle_call(:dispatch_next, _from, state) do
  case :queue.out(state.queue) do
    {{:value, request}, rest} ->
      next_state = %{
        state
        | queue: rest,
          inflight: Map.put(state.inflight, request.id, request)
      }

      :telemetry.execute(
        [:mars_colony, :maintenance_queue, :dispatch],
        %{queue_depth: :queue.len(rest)},
        %{request_id: request.id}
      )

      {:reply, {:ok, request}, next_state}

    {:empty, _queue} ->
      {:reply, :empty, state}
  end
end
```

The behavior is still the same queue from lesson 9. The difference is that the
runtime now narrates itself.

## Trying It Out

Run the lesson:

```bash
cd 10_telemetry_and_observability
mix test
```

You can also attach a telemetry handler in `iex`:

```bash
cd 10_telemetry_and_observability
iex -S mix
```

Then:

```elixir
:telemetry.attach(
  "queue-demo",
  [:mars_colony, :maintenance_queue, :enqueue],
  fn event, measurements, metadata, _config ->
    IO.inspect({event, measurements, metadata}, label: "telemetry")
  end,
  nil
)

TelemetryAndObservability.enqueue_request(%{
  id: "m-1",
  system: :water,
  action: "replace seal"
})
```

You should see a telemetry event with both measurements and metadata.

## What the Tests Prove

The test suite in
[`test/telemetry_and_observability_test.exs`](./test/telemetry_and_observability_test.exs)
proves that:

- enqueue emits a telemetry event with queue depth
- dispatch emits a telemetry event with queue depth
- request metadata is attached to those events

That is the real lesson. Observability becomes durable when it is emitted at the
same moment the state transition happens.

## Why This Matters

The colony can now publish operational facts while it runs.

The next problem is scale. Once sensor packets start arriving continuously,
single queue events are not enough. The colony needs a streaming model with
demand and staged processing.

## OTP Takeaway

Good instrumentation sits on the runtime boundary where something meaningful
happens.

It should not force the rest of the codebase to guess after the fact.

## What the Colony Can Do Now

The colony can now:

- keep the queue behavior from lesson 9
- emit queue depth as a measurement
- publish request metadata with runtime events
- support operators who want to observe without poking internals directly

The system has learned to leave tracks while it moves.

## What Still Hurts

Telemetry events are useful, but sensor traffic is not just isolated events
anymore. Once packets start flowing continuously, the colony needs real staged
stream processing.

## Next Lesson

[`11_genstage_resource_pipeline`](../11_genstage_resource_pipeline/README.md)
turns telemetry-style packets into a `GenStage` pipeline.
