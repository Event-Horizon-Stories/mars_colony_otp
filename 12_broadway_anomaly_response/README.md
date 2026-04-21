# Lesson 12: Broadway Anomaly Response

By this point the telemetry stream has stopped looking like a hand-built demo.

This chapter rebuilds anomaly handling as a Broadway pipeline so batching and
concurrency become part of the runtime contract instead of custom queue code.

## What You'll Learn

- how Broadway sits on top of streaming producers
- where batching belongs in an event pipeline
- how to keep the example practical instead of abstract

## Trying It Out

```bash
cd 12_broadway_anomaly_response
mix test
```
