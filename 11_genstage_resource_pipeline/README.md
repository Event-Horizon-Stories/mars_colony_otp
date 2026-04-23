# Lesson 11: Sensor Traffic Becomes a Real Stream

The colony can emit telemetry from discrete runtime actions. The next pressure
point is continuous sensor traffic.

Packets are now arriving from habitats, field equipment, and weather stations.
At that point, one queue and a few direct calls are not enough. The colony
needs staged flow with demand. The planet does not slow its signals down to
match human attention, so the runtime has to listen without losing judgment.

## What You'll Learn

By the end of this lesson, you should understand:

- how `GenStage` models producer, producer-consumer, and consumer stages
- why demand-driven flow matters once events are continuous
- how to break a data path into explicit runtime stages

## The Story

The colony’s sensor traffic has grown past the shape of isolated events.

Mars is speaking now in weather fronts, thermal drift, mineral noise, and
instrument chatter. The settlement cannot afford to treat each packet like a
small surprise. It needs a way to listen continuously without letting the flood
turn meaning back into static.

It has to let signal arrive without turning meaning back into static.

Packets now need to move through a pipeline:

- raw packets enter the system
- packets are normalized into a common shape
- suspicious packets are delivered to an anomaly sink

This is the first chapter where the runtime starts to look like a data
pipeline, not just a set of service processes.

## The OTP Concept

This chapter introduces `GenStage` because it answers a new question:

> what if data is flowing continuously, and consumers should pull according to
> demand instead of producers flooding them blindly?

That is the main difference between this lesson and the queue lesson before it.
The queue owned work intake. The pipeline coordinates staged flow.

## What This Chapter Adds

This lesson keeps habitats, rovers, tasks, alerts, the queue, and telemetry from
lesson 10 and adds:

- `GenstageResourcePipeline.SensorProducer`
- `GenstageResourcePipeline.Normalizer`
- `GenstageResourcePipeline.AnomalySink`
- public APIs to start the pipeline and publish sensor packets

## The Code

The lesson’s code lives in:

- [`lib/genstage_resource_pipeline/sensor_producer.ex`](./lib/genstage_resource_pipeline/sensor_producer.ex)
- [`lib/genstage_resource_pipeline/normalizer.ex`](./lib/genstage_resource_pipeline/normalizer.ex)
- [`lib/genstage_resource_pipeline.ex`](./lib/genstage_resource_pipeline.ex)
- [`test/genstage_resource_pipeline_test.exs`](./test/genstage_resource_pipeline_test.exs)

The producer owns the packet buffer and only releases events when there is
demand:

```elixir
@impl true
def init(:ok), do: {:producer, %{queue: :queue.new(), demand: 0}}

@impl true
def handle_call({:publish, packet}, _from, state) do
  next_state = %{state | queue: :queue.in(packet, state.queue)}
  {events, dispatched_state} = dispatch(next_state)
  {:reply, :ok, events, dispatched_state}
end

@impl true
def handle_demand(incoming_demand, state) when incoming_demand > 0 do
  # Consumers ask for more work, and only then do we dispatch.
  {events, next_state} = dispatch(%{state | demand: state.demand + incoming_demand})
  {:noreply, events, next_state}
end
```

The normalizer is a producer-consumer stage that reshapes data before it moves on:

```elixir
@impl true
def handle_events(events, _from, state) do
  normalized =
    Enum.map(events, fn event ->
      cond do
        # Convert temperatures into a common unit so downstream stages see one shape.
        Map.has_key?(event, :temperature_f) ->
          Map.put(event, :temperature_c, Float.round((event.temperature_f - 32) * 5 / 9, 1))

        true ->
          event
      end
    end)

  {:noreply, normalized, state}
end
```

The top-level API wires those stages together:

```elixir
def start_pipeline(opts) do
  producer_name = Keyword.get(opts, :producer_name, GenstageResourcePipeline.SensorProducer)
  notify = Keyword.fetch!(opts, :notify)

  {:ok, producer} = GenstageResourcePipeline.SensorProducer.start_link(name: producer_name)
  {:ok, normalizer} = GenstageResourcePipeline.Normalizer.start_link(upstream: producer)

  {:ok, sink} =
    GenstageResourcePipeline.AnomalySink.start_link(upstream: normalizer, notify: notify)

  {:ok, %{producer: producer, normalizer: normalizer, sink: sink}}
end
```

That is the lesson 11 leap: the colony stops treating packets like isolated
messages and starts treating them like a stream.

## Trying It Out

Run the lesson:

```bash
cd 11_genstage_resource_pipeline
mix test
```

You can also start the pipeline in `iex`:

```bash
cd 11_genstage_resource_pipeline
iex -S mix
```

Then:

```elixir
{:ok, pipeline} = GenstageResourcePipeline.start_pipeline(notify: self())

GenstageResourcePipeline.publish_sensor_packet(%{
  id: "pkt-1",
  source: "weather-tower",
  temperature_f: 86.0
}, pipeline.producer)

flush()
```

You should see the normalized packet reach the sink after flowing through the
producer and normalizer stages.

## What the Tests Prove

The test suite in
[`test/genstage_resource_pipeline_test.exs`](./test/genstage_resource_pipeline_test.exs)
proves that:

- packets can be published into the producer
- demand pulls those packets through the pipeline
- normalization happens before the sink receives the event

That ordering is the real lesson. The stages are not just modules. They express
a runtime flow.

## Why This Matters

The colony now has a true streaming path for sensor data.

The next question is practical ergonomics. Once a pipeline becomes serious
enough to care about batching and processing topology, Broadway becomes the more
comfortable abstraction.

## OTP Takeaway

`GenStage` is about demand-aware flow between stages.

It is what you reach for when the runtime needs to coordinate ongoing streams,
not just isolated requests.

## What the Colony Can Do Now

The colony can now:

- accept continuous sensor packets
- buffer them in a producer
- normalize them in a producer-consumer stage
- deliver them downstream according to demand

The colony’s data path finally feels like a pipeline.

## What Still Hurts

The pipeline works, but it still feels close to the machinery. If this path
needs clearer batching and a more production-shaped processing surface, the
colony needs one more abstraction.

## Next Lesson

[`12_broadway_anomaly_response`](../12_broadway_anomaly_response/README.md)
keeps the sensor path and rebuilds the anomaly side around Broadway.
