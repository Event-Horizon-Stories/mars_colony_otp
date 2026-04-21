# Lesson 07: Tasks and Timeouts

Not every unit of work deserves a permanent process.

Route planning and weather analysis are bursty, so this chapter runs them under
`Task.Supervisor` and makes timeout behavior explicit.

## What You'll Learn

- when a `Task` is a better fit than a long-lived `GenServer`
- how to run async work under supervision
- why timeout handling is part of the API contract

## Trying It Out

```bash
cd 07_tasks_and_timeouts
mix test
```
