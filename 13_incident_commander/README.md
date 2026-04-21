# Lesson 13: Incident Commander

The colony now knows enough to do more than restart crashed processes.

This chapter adds a coordinator that listens for alerts, records incident state,
and dispatches response work across subsystems.

## What You'll Learn

- how one process can orchestrate a multi-step response
- where coordination state belongs during an incident
- how alerts and action queues stay separate but connected

## Trying It Out

```bash
cd 13_incident_commander
mix test
```
