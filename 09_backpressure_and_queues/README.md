# Lesson 09: Backpressure and Queues

The colony can no longer assume every maintenance request gets handled
immediately.

This chapter puts one `GenServer` in charge of intake, buffering, and dispatch so
queue depth becomes explicit instead of hiding inside mailboxes.

## What You'll Learn

- how to own a queue inside one process
- how to expose overload as part of the API
- why explicit buffering is different from accidental backlog

## Trying It Out

```bash
cd 09_backpressure_and_queues
mix test
```
