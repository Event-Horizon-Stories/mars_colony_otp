# Lesson 14: One Shift Teaches the Next

By lesson 13, the colony has become a believable runtime:

- habitats with supervised life-support subsystems
- a top-level colony tree
- dynamic rovers
- supervised burst computation
- alert fan-out
- queue ownership and telemetry
- streaming and Broadway-based anomaly handling
- explicit incident coordination

The final gap is memory.

If the app restarts or one shift hands off to the next, selected operational
summaries should survive. Not everything needs persistence. But some things do.
Without that, the colony keeps paying twice for every hard lesson: once in the
event itself and once again in forgetting.

## What You'll Learn

By the end of this lesson, you should understand:

- how to add a narrow persistence boundary to an OTP system
- why selective persistence is often better than trying to persist everything
- how the single-node colony can reach a natural stopping point before
  distribution enters the story

## The Story

The colony has made it through detection, response, and repair.

Now the shift is ending. Boots slow down in the corridor. Voices get quieter.
The planet outside remains exactly as patient as it was at dawn.

Memory is how a settlement refuses to begin again from ignorance every time the
lights flicker, because on a world this unforgiving forgetting is just another
kind of avoidable loss.

The next crew should not need to reconstruct everything from memory. They need
a handoff surface that can preserve selected summaries across a restart:

- incident summaries
- shift notes
- high-level operational memory

That makes persistence a practical teaching topic instead of a vague “future
architecture” note.

## The OTP Concept

This chapter does not turn the colony into a database tutorial.

It introduces something narrower and more realistic:

> a small process that owns a durable boundary for a small class of state.

That is often the right first persistence step in OTP systems. Persist what
needs to survive. Keep the rest in normal runtime state.

## What This Chapter Adds

This lesson keeps the full colony from lesson 13 and adds:

- `PersistentShiftHandoff.HandoffLog`
- public APIs to start the log, record summaries, and read them back
- the single-node culmination of the series before distribution enters the story

## The Code

The lesson’s code lives in:

- [`lib/persistent_shift_handoff/handoff_log.ex`](./lib/persistent_shift_handoff/handoff_log.ex)
- [`lib/persistent_shift_handoff.ex`](./lib/persistent_shift_handoff.ex)
- [`test/persistent_shift_handoff_test.exs`](./test/persistent_shift_handoff_test.exs)

The handoff log is a normal `GenServer`, but its state has a durable boundary:

```elixir
@impl true
def init(opts) do
  path = Keyword.fetch!(opts, :path)
  {:ok, load_state(path)}
end

@impl true
def handle_call({:record_summary, summary}, _from, state) do
  next_state = %{state | summaries: state.summaries ++ [summary]}

  # Persist immediately so the handoff survives a process restart.
  persist!(next_state)
  {:reply, :ok, next_state}
end
```

The load path makes the recovery boundary obvious:

```elixir
defp load_state(path) do
  case File.read(path) do
    {:ok, binary} ->
      # Restore previously persisted summaries on boot.
      Map.put(:erlang.binary_to_term(binary), :path, path)

    {:error, :enoent} ->
      # Start clean if this is the first shift handoff file.
      %{path: path, summaries: []}
  end
end
```

And the public API makes the persistence boundary easy to use without exposing
the internals:

```elixir
def start_link(opts), do: HandoffLog.start_link(opts)
def record_summary(server, summary), do: HandoffLog.record_summary(server, summary)
def snapshot(server), do: HandoffLog.snapshot(server)
```

That is the chapter’s design argument. The colony keeps the full runtime it
built across the series, then adds one careful durable edge where it genuinely
helps.

## Trying It Out

Run the lesson:

```bash
cd 14_persistent_shift_handoff
mix test
```

You can also inspect the handoff log in `iex`:

```bash
cd 14_persistent_shift_handoff
iex -S mix
```

Then:

```elixir
path = Path.join(System.tmp_dir!(), "mars-handoff-demo.bin")
{:ok, server} = PersistentShiftHandoff.start_link(path: path)

:ok =
  PersistentShiftHandoff.record_summary(server, %{
    shift: "night",
    note: "thermal incident stabilized"
  })

PersistentShiftHandoff.snapshot(server)
```

You should see the summary preserved in the log state and persisted to disk.

## What the Tests Prove

The test suite in
[`test/persistent_shift_handoff_test.exs`](./test/persistent_shift_handoff_test.exs)
proves that:

- summaries can be recorded into the handoff log
- the persisted file can be read back on restart
- the rest of the final colony still works alongside that persistence boundary

That last point matters because this is an aggregate chapter. The colony did not
shrink to make room for persistence. Persistence arrived on top of the full
runtime built across the tutorial.

## Why This Matters

The colony can now preserve selected operational memory instead of losing every
useful summary at shutdown.

That solves one kind of durability problem. It does not solve geography. As soon
as a remote outpost begins running its own runtime, mission control still needs
to reach across a node boundary to inspect and coordinate it.

## OTP Takeaway

The strongest persistence lesson is usually a narrow one.

Persist the state that truly needs to outlive the process. Leave the rest as
ordinary runtime state until the system has earned more complexity.

## What the Colony Can Do Now

The colony can now:

- run the habitat and operations tree from the early chapters
- create temporary rovers and supervised tasks
- spread alerts across subscribers
- buffer and instrument maintenance work
- process sensor traffic through staged and Broadway-based pipelines
- coordinate incidents through an explicit commander
- preserve selected handoff summaries across restart

That is the aggregate single-node system this tutorial was building up to.

## What Still Hurts

The colony can preserve selected memory, but it is still a single-node world.

As soon as a remote outpost begins running its own copy of the colony, mission
control needs a way to connect to that node, query its state, and discover one
remote service cleanly.

## Next Lesson

[`15_distributed_outposts`](../15_distributed_outposts/README.md) adds a remote
outpost node and teaches the first practical distributed Elixir tools:
`Node.connect/1`, `:rpc`, and one globally named beacon.
