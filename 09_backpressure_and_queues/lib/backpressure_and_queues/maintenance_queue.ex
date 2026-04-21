defmodule BackpressureAndQueues.MaintenanceQueue do
  @moduledoc """
  Owns the maintenance intake queue for the colony.

  The key lesson here is not "how to use `:queue`." The key lesson is that one
  process should own both the buffered work and the overload decision so the
  rest of the system has one place to ask about pressure.
  """

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
       # Requests waiting to be worked on.
       queue: :queue.new(),
       # Requests already handed out but not finished yet.
       inflight: %{},
       max_queue: Keyword.get(opts, :max_queue, 3)
     }}
  end

  @impl true
  def handle_call({:enqueue, request}, _from, state) do
    next_queue = :queue.in(request, state.queue)
    next_state = %{state | queue: next_queue}

    # Returning overload status here makes backpressure explicit to the caller.
    overloaded = :queue.len(next_queue) > state.max_queue
    {:reply, {:ok, overloaded}, next_state}
  end

  def handle_call(:dispatch_next, _from, state) do
    case :queue.out(state.queue) do
      {{:value, request}, rest} ->
        next_state = %{
          state
          | queue: rest,
            # Once dispatched, the request moves out of the queue and into inflight tracking.
            inflight: Map.put(state.inflight, request.id, request)
        }

        {:reply, {:ok, request}, next_state}

      {:empty, _queue} ->
        {:reply, :empty, state}
    end
  end

  def handle_call({:ack, id}, _from, state) do
    # Acknowledgement means the work is complete and should disappear from inflight.
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
