defmodule ColonyControlTree.DomainService do
  @moduledoc """
  A tiny named service used to make top-level branches visible in the runtime.

  This process is intentionally minimal. Its job is to give the lesson a
  concrete process under each branch so beginners can look it up, inspect it,
  and even crash it on purpose.
  """

  use GenServer

  def start_link(opts) do
    service = Keyword.fetch!(opts, :service)
    name = {:via, Registry, {ColonyControlTree.Registry, service}}
    GenServer.start_link(__MODULE__, %{service: service}, name: name)
  end

  def snapshot(pid), do: GenServer.call(pid, :snapshot)
  def induce_failure(pid), do: GenServer.call(pid, :induce_failure)

  @impl true
  def init(state), do: {:ok, Map.put(state, :status, :online)}

  @impl true
  def handle_call(:snapshot, _from, state), do: {:reply, state, state}

  def handle_call(:induce_failure, _from, state) do
    # We stop deliberately so the supervising branch can show its restart behavior.
    {:stop, {:shutdown, :simulated_failure}, :ok, state}
  end
end
