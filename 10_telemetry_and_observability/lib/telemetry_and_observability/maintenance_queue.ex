defmodule TelemetryAndObservability.MaintenanceQueue do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def enqueue(request), do: GenServer.call(__MODULE__, {:enqueue, request})
  def dispatch_next, do: GenServer.call(__MODULE__, :dispatch_next)
  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(opts) do
    {:ok,
     %{
       queue: :queue.new(),
       max_queue: Keyword.get(opts, :max_queue, 4)
     }}
  end

  @impl true
  def handle_call({:enqueue, request}, _from, state) do
    next_queue = :queue.in(request, state.queue)
    queue_depth = :queue.len(next_queue)

    :telemetry.execute(
      [:mars_colony, :maintenance_queue, :enqueue],
      %{queue_depth: queue_depth},
      %{request_id: request.id, overloaded?: queue_depth > state.max_queue}
    )

    {:reply, :ok, %{state | queue: next_queue}}
  end

  def handle_call(:dispatch_next, _from, state) do
    case :queue.out(state.queue) do
      {{:value, request}, rest} ->
        :telemetry.execute(
          [:mars_colony, :maintenance_queue, :dispatch],
          %{queue_depth: :queue.len(rest)},
          %{request_id: request.id}
        )

        {:reply, {:ok, request}, %{state | queue: rest}}

      {:empty, _queue} ->
        {:reply, :empty, state}
    end
  end

  def handle_call(:snapshot, _from, state) do
    {:reply, %{queued: :queue.to_list(state.queue)}, state}
  end
end
