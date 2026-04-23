# Lesson 12: The Anomaly Path Becomes Production-Shaped

Lesson 11 gave the colony a real `GenStage` pipeline. That was the right next
step for learning demand-driven flow, but it still sits close to the machinery.

Once anomaly handling starts to feel like operational infrastructure, Broadway
is a better teaching surface. It keeps the staged flow idea while adding a more
comfortable shape for processing and batching.

By now the colony knows that strange readings are not interruptions to the
story. They are part of what the world has been saying all along.

## What You'll Learn

By the end of this lesson, you should understand:

- how Broadway layers on top of staged processing
- how processor and batcher topology shape runtime behavior
- why batching is useful for critical anomaly handling paths

## The Story

The sensor path is now mature enough to deserve production-style handling.

By now the colony has lived with enough strange readings to know that mystery
is not the exceptional state of the universe. It is the ordinary one. The real
question is whether the runtime can meet strangeness with discipline instead of
thrashing.

Maturity is not the end of uncertainty. It is a steadier way of receiving it.

The better the runtime gets, the less drama it needs to stay composed in the
presence of the unknown.

The colony still needs the same high-level steps:

- events enter the anomaly path
- non-critical events are processed normally
- critical events are grouped and handled as batches

But the colony no longer wants to hand-build every stage interaction itself.

## The OTP Concept

This chapter introduces Broadway for a practical reason:

> once the pipeline shape is stable, a higher-level stream-processing tool can
> make concurrency and batching easier to reason about.

The idea is not “Broadway instead of OTP.” The idea is Broadway as a more
comfortable OTP-shaped abstraction for this class of workload.

## What This Chapter Adds

This lesson keeps habitats, rovers, tasks, alerts, queue ownership, telemetry,
and the earlier sensor path from lesson 11, then adds:

- `BroadwayAnomalyResponse.Pipeline`
- `BroadwayAnomalyResponse.Producer`
- `BroadwayAnomalyResponse.Transformer`
- `start_sensor_pipeline/1` as the carried-forward GenStage sensor path
- `start_pipeline/1` as the new Broadway anomaly path entrypoint
- public APIs to push events into both flows

## The Code

The lesson’s code lives in:

- [`lib/broadway_anomaly_response/pipeline.ex`](./lib/broadway_anomaly_response/pipeline.ex)
- [`lib/broadway_anomaly_response.ex`](./lib/broadway_anomaly_response.ex)
- [`test/broadway_anomaly_response_test.exs`](./test/broadway_anomaly_response_test.exs)

The Broadway topology makes the runtime shape explicit:

```elixir
def start_link(opts) do
  notify = Keyword.fetch!(opts, :notify)
  broadway_name = Keyword.fetch!(opts, :name)

  Broadway.start_link(__MODULE__,
    name: broadway_name,
    context: %{notify: notify},
    producer: [
      module: {BroadwayAnomalyResponse.Producer, []},
      transformer: {BroadwayAnomalyResponse.Transformer, :transform, []},
      concurrency: 1
    ],
    processors: [
      default: [concurrency: 1]
    ],
    batchers: [
      critical: [concurrency: 1, batch_size: 2, batch_timeout: 50]
    ]
  )
end
```

That says, in one place, how events enter, how they are processed, and how
critical ones are batched.

One continuity detail is easy to miss: lesson 11 used `start_pipeline/1` for
the hand-built GenStage path. In this lesson that earlier path is still present,
but it now lives behind `start_sensor_pipeline/1` so `start_pipeline/1` can name
the new Broadway runtime directly.

The message handler decides which events should be batched:

```elixir
@impl true
def handle_message(_processor, message, _context) do
  data = message.data
  batcher = if data.severity == :critical, do: :critical, else: :default

  message
  # Route only critical events into the critical batcher.
  |> Broadway.Message.put_batcher(batcher)
  # Mark the payload so downstream code can see it has passed through classification.
  |> Broadway.Message.update_data(fn payload -> Map.put(payload, :classified, true) end)
end
```

And the batch handler demonstrates why batching exists in the first place:

```elixir
def handle_batch(:critical, messages, _batch_info, context) do
  ids = Enum.map(messages, & &1.data.id)

  # Notify the outside world with one grouped signal instead of many scattered ones.
  send(context.notify, {:critical_batch, ids})
  messages
end
```

## Trying It Out

Run the lesson:

```bash
cd 12_broadway_anomaly_response
mix test
```

You can also watch a critical batch form in `iex`:

```bash
cd 12_broadway_anomaly_response
iex -S mix
```

Then:

```elixir
{:ok, _pid} = BroadwayAnomalyResponse.start_pipeline(name: DemoPipeline, notify: self())

BroadwayAnomalyResponse.push_event(%{id: "a-1", severity: :critical}, DemoPipeline)
BroadwayAnomalyResponse.push_event(%{id: "a-2", severity: :critical}, DemoPipeline)

flush()
```

You should see one batch notification containing both critical event IDs.

## What the Tests Prove

The test suite in
[`test/broadway_anomaly_response_test.exs`](./test/broadway_anomaly_response_test.exs)
proves that:

- events can be pushed into the Broadway pipeline
- critical events are routed into the critical batcher
- critical batches are emitted as grouped signals

That last point is the real lesson. Broadway is helping the colony express a
production-shaped processing path, not just a demo stream.

## Why This Matters

The colony now has a more operational anomaly path.

The next pressure is coordination. Once alerts are serious enough to trigger
repairs and load-shedding, the system needs one place to own incident response
state.

## OTP Takeaway

Broadway is a good fit when a streaming path has graduated from “learn the stage
machinery” to “run a recognizable processing topology.”

## What the Colony Can Do Now

The colony can now:

- keep the broader runtime built in earlier lessons
- keep the lesson 11 sensor path under `start_sensor_pipeline/1`
- run a production-shaped anomaly pipeline
- classify events and route critical ones into a batcher
- emit grouped critical responses instead of isolated event noise

The colony’s data path now feels like something operations would actually trust.

## What Still Hurts

The anomaly path can identify trouble, but the colony still needs one place to
turn that trouble into coordinated action.

## Next Lesson

[`13_incident_commander`](../13_incident_commander/README.md) adds a runtime
owner for incident response.
