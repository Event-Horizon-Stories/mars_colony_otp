# Lesson 05: Colony Control Tree

This is the point where the system starts looking like a colony instead of a
single habitat with helpers.

Mission control, storage, and communications now boot under separate top-level
branches so the runtime can grow by domain instead of by accident.

## What You'll Learn

- how to compose a top-level supervision tree
- why domains deserve separate branches
- how to verify that one branch crash does not take down the others

## Trying It Out

```bash
cd 05_colony_control_tree
mix test
```
