# Lesson 11: GenStage Resource Pipeline

The colony's sensor stream is now large enough to deserve a demand-driven
pipeline instead of ad hoc message fan-out.

This chapter moves telemetry through a `GenStage` producer, a normalization
stage, and an anomaly sink.

## What You'll Learn

- how demand flows from consumers back to producers
- when a producer-consumer stage is useful
- how to keep streaming transformations narrow and testable

## Trying It Out

```bash
cd 11_genstage_resource_pipeline
mix test
```
