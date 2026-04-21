# Lesson 06: Dynamic Rovers

Rovers should not all exist at boot.

This chapter introduces a `DynamicSupervisor` so the colony can launch survey,
repair, and cargo rovers only when missions actually exist.

## What You'll Learn

- how to supervise runtime-created workers
- why on-demand workers are different from static boot children
- how to retire a worker cleanly when its mission ends

## Trying It Out

```bash
cd 06_dynamic_rovers
mix test
```
