# Lesson 00: A Process Is a Loop With a Mailbox

Before the first habitat is bolted into Martian soil, the colony is still in
transit.

The ship has one pressurized habitat ring, one crew, and one operator watching
oxygen, water, and power during the long flight in. The numbers repeat so often
they start to sound like prayer, and prayer is often only another way of
counting what cannot be wasted. Outside the hull, space offers no answer back.
Inside, even a simple status reply feels like proof that order still exists
somewhere.

That makes this a good place to meet the raw process model.

We start one transit habitat with `spawn_link/1`, keep its state in a recursive
loop, send it messages, and manually wait for replies. The code is intentionally
a little awkward. That awkwardness is the lesson.

## What You'll Learn

By the end of this lesson, you should understand:

- how to start a process with `spawn_link/1`
- how a recursive `loop(state)` keeps process state alive
- how `send/2` and `receive` form a manual protocol
- why request refs are useful when building reply messages by hand
- what starts to feel repetitive before `GenServer` enters the story

## The Story

The colony ship is still flying toward Mars.

Nothing is a settlement yet. There is no base command tree, no rover fleet, and
no maintenance district. There is only one transit habitat that has to stay
alive for the rest of the journey, one moving room held together by routine and
the private fear that routine may not be enough forever.

An operator in the flight deck only needs that habitat loop to do four things:

- report its current status
- consume oxygen, water, or power
- schedule maintenance work
- stop cleanly

Nothing is supervised. Nothing is named. Nothing is structured for reuse. It is
just one shipboard system talking to one long-lived process while Mars waits on
the other side of months.

Long before Mars becomes a home, it is a measure of how calmly people can face
what does not care whether they live, which makes the first loop feel smaller
than history and more important than it has any right to be.

That is exactly why this is a useful place to begin.

## The OTP Concept

This chapter teaches the low-level mental model behind a server process:

> a process can keep state alive by waiting for messages and calling itself again
> with the next version of that state.

That is the raw shape OTP abstractions build on top of.

## What We're Building

We will create:

- `ProcessLoop`
- `ProcessLoop.HabitatLoop`

The process can:

- start with some initial transit-habitat state
- receive manual request tuples
- reply to the caller with a request ref
- recurse with updated state after each handled message

## The Code

The lesson’s code lives in:

- [`lib/process_loop.ex`](./lib/process_loop.ex)
- [`lib/process_loop/habitat_loop.ex`](./lib/process_loop/habitat_loop.ex)
- [`test/process_loop_test.exs`](./test/process_loop_test.exs)

The public API wraps the raw mailbox protocol so the tests and `iex` examples
stay readable:

```elixir
def start(initial_state \\ %{}) do
  HabitatLoop.start(initial_state)
end

def get_status(server, timeout \\ 100) do
  request(server, :get_status, timeout)
end

def consume_resource(server, resource, amount, timeout \\ 100) do
  request(server, {:consume_resource, resource, amount}, timeout)
end

defp request(server, message, timeout) do
  ref = make_ref()

  send(server, {message, self(), ref})

  receive do
    {^ref, reply} -> reply
  after
    timeout -> {:error, :timeout}
  end
end
```

This is already enough to expose one important truth: once you build a live
process by hand, you also have to build its request protocol by hand.

The process loop itself is the center of the chapter:

```elixir
def start(initial_state \\ %{}) do
  spawn_link(fn -> loop(normalize_state(initial_state)) end)
end

defp loop(state) do
  receive do
    {:get_status, caller, ref} ->
      send(caller, {ref, {:ok, state}})
      loop(state)

    {{:consume_resource, resource, amount}, caller, ref}
    when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 ->
      next_state =
        state
        |> Map.update!(resource, &max(&1 - amount, 0))
        |> append_status("#{resource} adjusted to #{Map.fetch!(state, resource) - amount |> max(0)}")

      send(caller, {ref, {:ok, next_state}})
      loop(next_state)

    {:stop, caller, ref} ->
      send(caller, {ref, :ok})
      :ok

    _unknown_message ->
      loop(state)
  end
end
```

That one function shows almost everything chapter 2 will later clean up:

- state is kept manually
- every message shape is matched manually
- every reply is sent manually
- every timeout has to be invented by the caller

The shipboard setting helps here because the system is believable at this
smaller scale. One operator really could be talking to one process that owns the
current life-support numbers for one transit habitat.

## Trying It Out

Run the lesson:

```bash
cd 00_process_loop
mix test
```

You can also inspect the manual protocol in `iex`:

```bash
cd 00_process_loop
iex -S mix
```

Then:

```elixir
server = ProcessLoop.start(%{habitat: "transfer-ring-a", oxygen: 100})

ProcessLoop.get_status(server)
ProcessLoop.consume_resource(server, :oxygen, 20)
ProcessLoop.schedule_maintenance(server, "co2 scrubber")
ProcessLoop.get_status(server)
ProcessLoop.stop(server)
```

You should see a live process that keeps state between messages even though no
OTP behavior has been added yet.

## What the Tests Prove

The test suite in [`test/process_loop_test.exs`](./test/process_loop_test.exs)
proves two things:

- a spawned process loop can keep and update habitat state across messages
- the manual protocol depends on request refs and caller-side timeouts

That second point matters because it shows where the repetition starts.

## Why This Matters

This lesson is not trying to convince you to hand-roll servers forever.

It is doing something more useful:

- showing the shape of a mailbox-driven process
- showing why that shape is powerful
- showing why it becomes tedious quickly

That makes `GenServer` feel earned instead of magical when it appears later.

## OTP Takeaway

A process is not mysterious.

At its core, it is a loop with state and a mailbox.

OTP becomes easier to learn once that stops feeling abstract.

## What the Colony Can Do Now

The colony can now:

- spawn one live habitat process
- send it manual request messages
- receive replies through refs
- stop the process cleanly

It is rough, but it is alive.

## What Still Hurts

Everything about the protocol is hand-built:

- message shapes
- reply shapes
- timeout handling
- state transitions mixed into mailbox code

## Next Lesson

Lesson 1 begins after touchdown.

That rewind is useful. After seeing the shipboard habitat as a live mailbox
loop, we can step back and ask a cleaner question on the surface:

what should a habitat state transition look like before we wrap it in a
process?

That is fine for a prelude. It is not yet a good foundation for a growing
system.

## Next Lesson

[`01_habitat_bootstrap`](../01_habitat_bootstrap/README.md) steps back from the
raw mailbox and focuses on pure state transitions before the colony starts
leaning on OTP.
