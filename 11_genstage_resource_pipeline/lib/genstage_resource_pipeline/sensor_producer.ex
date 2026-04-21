defmodule GenstageResourcePipeline.SensorProducer do
  @moduledoc """
  The producer stage for raw sensor packets.

  Beginner note:
  `GenStage` producers do not push endlessly on their own. They keep track of
  how much downstream demand exists and only release that much work.
  """

  use GenStage

  def start_link(opts) do
    name = Keyword.get(opts, :name)
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  def publish(server, packet), do: GenStage.call(server, {:publish, packet})

  # The producer starts with no buffered events and no downstream demand.
  @impl true
  def init(:ok), do: {:producer, %{queue: :queue.new(), demand: 0}}

  @impl true
  def handle_call({:publish, packet}, _from, state) do
    next_state = %{state | queue: :queue.in(packet, state.queue)}
    {events, dispatched_state} = dispatch(next_state)
    {:reply, :ok, events, dispatched_state}
  end

  @impl true
  def handle_demand(incoming_demand, state) when incoming_demand > 0 do
    # Consumers ask for more work through demand, not through direct function calls.
    {events, next_state} = dispatch(%{state | demand: state.demand + incoming_demand})
    {:noreply, events, next_state}
  end

  defp dispatch(%{queue: queue, demand: demand} = state) do
    # Never emit more items than both the queue and the downstream demand allow.
    amount = min(:queue.len(queue), demand)
    {items, rest} = pop_many(queue, amount, [])
    {Enum.reverse(items), %{state | queue: rest, demand: demand - amount}}
  end

  defp pop_many(queue, 0, acc), do: {acc, queue}

  defp pop_many(queue, amount, acc) do
    {{:value, item}, rest} = :queue.out(queue)
    pop_many(rest, amount - 1, [item | acc])
  end
end
