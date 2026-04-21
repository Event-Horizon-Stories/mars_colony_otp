defmodule DistributedOutposts.MaintenanceQueue do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def enqueue(request), do: GenServer.call(__MODULE__, {:enqueue, request})
  def dispatch_next, do: GenServer.call(__MODULE__, :dispatch_next)
  def ack(id), do: GenServer.call(__MODULE__, {:ack, id})
  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(opts) do
    {:ok,
     %{
       queue: :queue.new(),
       inflight: %{},
       max_queue: Keyword.get(opts, :max_queue, 3)
     }}
  end

  @impl true
  def handle_call({:enqueue, request}, _from, state) do
    next_queue = :queue.in(request, state.queue)
    next_state = %{state | queue: next_queue}
    overloaded = :queue.len(next_queue) > state.max_queue

    :telemetry.execute(
      [:mars_colony, :maintenance_queue, :enqueue],
      %{queue_depth: :queue.len(next_queue)},
      %{request_id: request.id, overloaded?: overloaded}
    )

    {:reply, :ok, next_state}
  end

  def handle_call(:dispatch_next, _from, state) do
    case :queue.out(state.queue) do
      {{:value, request}, rest} ->
        next_state = %{
          state
          | queue: rest,
            inflight: Map.put(state.inflight, request.id, request)
        }

        :telemetry.execute(
          [:mars_colony, :maintenance_queue, :dispatch],
          %{queue_depth: :queue.len(rest)},
          %{request_id: request.id}
        )

        {:reply, {:ok, request}, next_state}

      {:empty, _queue} ->
        {:reply, :empty, state}
    end
  end

  def handle_call({:ack, id}, _from, state) do
    {:reply, :ok, %{state | inflight: Map.delete(state.inflight, id)}}
  end

  def handle_call(:snapshot, _from, state) do
    reply = %{
      queued: :queue.to_list(state.queue),
      inflight: state.inflight,
      max_queue: state.max_queue
    }

    {:reply, reply, state}
  end
end
