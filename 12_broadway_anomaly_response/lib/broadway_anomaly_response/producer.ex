defmodule BroadwayAnomalyResponse.Producer do
  @moduledoc false

  use GenStage

  def push_event(server, event), do: GenStage.call(server, {:push_event, event})

  @impl true
  def init(_opts), do: {:producer, %{queue: :queue.new(), demand: 0}}

  @impl true
  def handle_call({:push_event, event}, _from, state) do
    next_state = %{state | queue: :queue.in(event, state.queue)}
    {events, dispatched_state} = dispatch(next_state)
    {:reply, :ok, events, dispatched_state}
  end

  @impl true
  def handle_demand(incoming_demand, state) when incoming_demand > 0 do
    {events, next_state} = dispatch(%{state | demand: state.demand + incoming_demand})
    {:noreply, events, next_state}
  end

  defp dispatch(%{queue: queue, demand: demand} = state) do
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
