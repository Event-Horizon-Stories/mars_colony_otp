defmodule DistributedOutposts.DomainService do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    service = Keyword.fetch!(opts, :service)
    name = {:via, Registry, {DistributedOutposts.Registry, service}}
    GenServer.start_link(__MODULE__, %{service: service}, name: name)
  end

  def snapshot(pid), do: GenServer.call(pid, :snapshot)
  def induce_failure(pid), do: GenServer.call(pid, :induce_failure)

  @impl true
  def init(state), do: {:ok, Map.put(state, :status, :online)}

  @impl true
  def handle_call(:snapshot, _from, state), do: {:reply, state, state}

  def handle_call(:induce_failure, _from, state) do
    {:stop, {:shutdown, :simulated_failure}, :ok, state}
  end
end
