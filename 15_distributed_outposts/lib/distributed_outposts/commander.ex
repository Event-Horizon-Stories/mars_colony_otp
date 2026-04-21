defmodule DistributedOutposts.Commander do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(_opts) do
    # Subscribe during init so critical alerts are not dropped during startup.
    DistributedOutposts.AlertBus.subscribe(:critical_alerts)
    {:ok, %{active_incidents: [], response_log: []}}
  end

  @impl true
  def handle_info({:incident_alert, :critical_alerts, alert}, state) do
    # The commander is an orchestrator, not the worker that performs the repair.
    # It reacts to the alert by placing concrete work onto the maintenance queue.
    action = %{id: "repair-#{alert.system}", system: alert.system, action: "dispatch repair crew"}
    :ok = DistributedOutposts.MaintenanceQueue.enqueue(action)

    next_state = %{
      state
      | active_incidents: state.active_incidents ++ [alert],
        response_log: state.response_log ++ ["reroute load and dispatch #{alert.system} repair"]
    }

    {:noreply, next_state}
  end

  @impl true
  def handle_call(:snapshot, _from, state), do: {:reply, state, state}
end
