defmodule DistributedOutposts.OutpostBeacon do
  @moduledoc """
  A tiny locally named process that can also be registered globally across nodes.

  The beacon keeps the distributed lesson small. It does not own the whole
  colony. It simply exposes one place that remote nodes can discover and query
  for a compact outpost summary.
  """

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
      :undefined ->
        :global.register_name(name, pid)

      ^pid ->
        :yes

      _other_pid ->
        :no
    end
  end

  def snapshot(server \\ __MODULE__), do: GenServer.call(server, :snapshot)

  @impl true
  def init(_opts) do
    # Register after boot so the lesson can show a beacon that becomes
    # globally discoverable as part of the normal application startup.
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
    # Pull the current runtime facts at call time so the beacon always reflects
    # the latest incident and queue state on this node.
    reply = DistributedOutposts.local_cluster_snapshot()
    {:reply, reply, state}
  end
end
