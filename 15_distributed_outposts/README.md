# Lesson 15: The Colony Spreads Across Nodes

The colony can now run a believable single-node runtime:

- habitats with supervised life-support subsystems
- a top-level colony tree
- dynamic rovers
- supervised burst computation
- alert fan-out
- queue ownership and telemetry
- streaming and Broadway-based anomaly handling
- explicit incident coordination
- persistent shift handoff

The next pressure is geography.

One node is no longer enough. A remote outpost is running its own copy of the
colony, and mission control needs a clean way to connect to it, ask for state,
and discover one small globally named service. Distance on one planet is still
distance. Once the settlement extends beyond one machine room, geography becomes
part of the system design.

## What You'll Learn

By the end of this lesson, you should understand:

- how to connect BEAM nodes with `Node.connect/1`
- how to query remote state with `:rpc.call/4`
- how `:global` can expose one discoverable process across connected nodes
- how to add a distributed chapter without throwing away the full single-node
  colony from earlier lessons

## The Story

The colony has outgrown one machine room.

Mission control still runs at the main base, but now there is a remote outpost
operating on another node. Between them lies enough dust, weather, and empty
ground to remind everyone that the edge of the world does not have to be
interstellar to feel immense. Even on one planet, the known world can end just
beyond the last reliable reply. That outpost boots the same application tree as
mission control, but this lesson only asks about the parts that matter first:
Mars does not need stars to feel infinite; sometimes one delayed answer across
red ground is enough.

- habitat tree
- repair queue
- incident commander
- outpost beacon

This chapter is about what changes when those systems live on another node.

Mission control needs to do three small but real things:

- connect to the remote node
- ask the remote node for incident and queue state
- find one remote outpost beacon through a global name instead of a raw PID

That is enough to introduce distributed Elixir without turning the tutorial
into cluster choreography.

The core OTP idea stays small. The interactive setup is a little heavier because
starting a second BEAM node introduces some operational mechanics all at once:
named nodes, a shared cookie, a code path for the fresh VM, and a remote app
boot step.

## The OTP Concept

This chapter introduces the first real distributed boundary in the series:

> some useful runtime facts now live on another BEAM node.

The lesson stays deliberately small:

- we do not add automatic cluster membership
- we do not add network partitions or multi-node supervision
- we do not try to distribute every process in the colony

We simply show how a node becomes addressable, queryable, and discoverable.

## What This Chapter Adds

This lesson keeps the full chapter 14 colony and adds:

- `DistributedOutposts.connect_outpost/1`
- remote state queries through `:rpc`
- `DistributedOutposts.OutpostBeacon`
- global outpost registration and lookup through `:global`

## The Code

The lesson’s code lives in:

- [`lib/distributed_outposts.ex`](./lib/distributed_outposts.ex)
- [`lib/distributed_outposts/application.ex`](./lib/distributed_outposts/application.ex)
- [`lib/distributed_outposts/outpost_beacon.ex`](./lib/distributed_outposts/outpost_beacon.ex)
- [`test/distributed_outposts_test.exs`](./test/distributed_outposts_test.exs)

The public API makes the node boundary explicit:

```elixir
def connect_outpost(node_name) when is_atom(node_name) do
  with true <- Node.connect(node_name),
       :ok <- ensure_local_outpost_registered(node()),
       :ok <- ensure_remote_outpost_registered(node_name),
       :ok <- :global.sync() do
    true
  else
    false -> {:error, :node_unreachable}
    :ignored -> {:error, :connection_ignored}
    {:error, _reason} = error -> error
  end
end

def remote_incident_snapshot(node_name) when is_atom(node_name) do
  :rpc.call(node_name, __MODULE__, :incident_snapshot, [])
end

def remote_queue_snapshot(node_name) when is_atom(node_name) do
  :rpc.call(node_name, __MODULE__, :queue_snapshot, [])
end
```

That is the first distributed move of the lesson:

- connect to another node
- run a normal function there
- get the result back

The code looks simple because `connect_outpost/1` hides some setup work that is
necessary in a tutorial:

- the remote node needs a shared cookie before nodes can trust each other
- the remote node needs the lesson beam files on its code path
- the remote app still has to be started before you can call into it

It also returns structured errors instead of crashing if node connection or
beacon registration fails. That keeps the public API honest about distributed
failure. The helper functions in the real module keep that error translation out
of the happy-path example.

The outpost beacon teaches a second distributed move:

```elixir
def register_outpost(outpost_id \\ node()) when is_atom(outpost_id) do
  OutpostBeacon.register_global(outpost_id)
end

def outpost_snapshot(outpost_id) when is_atom(outpost_id) do
  case lookup_outpost_beacon(outpost_id) do
    :undefined ->
      :error

    pid ->
      try do
        {:ok, OutpostBeacon.snapshot(pid)}
      catch
        :exit, reason -> {:error, reason}
      end
  end
end

defp lookup_outpost_beacon(outpost_id) do
  name = {:outpost_beacon, outpost_id}

  case :global.whereis_name(name) do
    :undefined ->
      :ok = :global.sync()
      :global.whereis_name(name)

    pid ->
      pid
  end
end
```

That gives the cluster one small globally discoverable process per outpost
without pretending that everything in the colony should be globally named.

The beacon itself stays intentionally small:

```elixir
defmodule DistributedOutposts.OutpostBeacon do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def register_global(outpost_id, server \\ __MODULE__) when is_atom(outpost_id) do
    pid =
      case server do
        pid when is_pid(pid) -> pid
        name -> GenServer.whereis(name)
      end

    name = {:outpost_beacon, outpost_id}

    case :global.whereis_name(name) do
      :undefined -> :global.register_name(name, pid)
      ^pid -> :yes
      _other_pid -> :no
    end
  end

  def snapshot(server \\ __MODULE__), do: GenServer.call(server, :snapshot)

  @impl true
  def init(_opts) do
    if Node.alive?() do
      send(self(), :register_global_name)
    end

    {:ok, %{}}
  end

  @impl true
  def handle_info(:register_global_name, state) do
    :yes = register_global(node(), self())
    {:noreply, state}
  end

  @impl true
  def handle_call(:snapshot, _from, state) do
    # Summarize the local node at call time so remote readers get fresh state.
    reply = DistributedOutposts.local_cluster_snapshot()
    {:reply, reply, state}
  end
end
```

The beacon is not another orchestrator. It is a tiny discoverable window into
the outpost node.

## Trying It Out

Run the lesson:

```bash
cd 15_distributed_outposts
mix test
```

You can also inspect the distributed chapter directly in `iex`.

Start the lesson as a named local node:

```bash
cd 15_distributed_outposts
iex --sname mission_control -S mix
```

Then start a peer outpost and talk to it:

```elixir
peer_args =
  [~c"-setcookie", Atom.to_charlist(Node.get_cookie())] ++
    Enum.flat_map(:code.get_path(), fn path -> [~c"-pa", path] end)

{:ok, peer, remote_node} =
  :peer.start_link(%{
    name: :outpost_alpha,
    args: peer_args
  })

{:ok, _started} =
  :rpc.call(remote_node, :application, :ensure_all_started, [:distributed_outposts])

DistributedOutposts.connect_outpost(remote_node)

{:ok, _pid} =
  :rpc.call(remote_node, DistributedOutposts, :start_habitat, ["outpost-a"])

:ok =
  :rpc.call(remote_node, DistributedOutposts, :report_alert, [
    %{habitat: "outpost-a", system: :thermal, severity: :critical}
  ])

Process.sleep(50)

DistributedOutposts.remote_incident_snapshot(remote_node)
DistributedOutposts.outpost_snapshot(remote_node)
```

You should see remote incident state through `:rpc`, then a compact remote
summary through the globally discoverable outpost beacon. The extra `-pa`
arguments matter: the peer is a fresh VM, so it must be told where the compiled
lesson and dependency beam files live.

If that setup feels denser than the rest of the series, that is normal. The
distributed concept in this lesson is still narrow:

- `Node.connect/1` joins the nodes
- `:rpc.call/4` runs a function on the remote node
- `:global` gives the cluster one discoverable name for the outpost beacon

The remote node is also running the rest of the colony tree, because the lesson
keeps the cumulative application shape intact. We simply focus our remote
queries on the habitat, queue, commander, and beacon because those are enough
to teach the first distributed boundary clearly.

## What the Tests Prove

The test suite in
[`test/distributed_outposts_test.exs`](./test/distributed_outposts_test.exs)
proves three things:

- mission control can connect to a remote outpost node and query its incident
  and queue state through `:rpc`
- a remote outpost beacon can be registered globally and discovered from another
  node
- discovery failures return an error tuple instead of crashing the caller

That second point matters because it keeps the distributed lesson concrete.
There is one small globally named process with one clear purpose.

## Why This Matters

The tutorial now reaches its natural edge.

The colony can do useful work on one node, and it can reach across to another
node when geography demands it. That is enough to make distributed Elixir feel
real without introducing cluster automation, failover strategies, or network
partition recovery all at once.

## OTP Takeaway

Distributed Elixir becomes much easier to learn when the first lesson is narrow:

- connect to another node
- call a function there
- expose one remote process through a global name

That is enough to understand the shape before adding bigger cluster machinery.

## What the Colony Can Do Now

The final colony can now:

- run the full single-node runtime from chapter 14
- connect to a remote outpost node
- pull remote incident and queue state through `:rpc`
- discover one remote outpost beacon through `:global`

The colony is no longer just one healthy node. It is the beginning of a real
distributed system.

## Where To Go Next

From here, the natural extensions are:

- cluster formation and node discovery
- remote process handoff and failover strategy
- network partition handling
- distributed registries and more advanced naming strategies
- higher-volume durable storage and cross-node recovery workflows

The core distributed lesson is already complete. The colony now has a believable
reason to care that another BEAM node exists.
