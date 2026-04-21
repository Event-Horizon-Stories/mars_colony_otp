# Lesson 08: PubSub Alerts

The colony now has events that multiple teams care about at once.

This chapter uses a duplicate `Registry` as a small local event bus so habitat
alarms can fan out to whoever is listening.

## What You'll Learn

- how to broadcast locally without hard-coding receivers
- why subscriptions reduce coupling between publishers and listeners
- how to prove fan-out behavior in tests

## Trying It Out

```bash
cd 08_pubsub_alerts
mix test
```
