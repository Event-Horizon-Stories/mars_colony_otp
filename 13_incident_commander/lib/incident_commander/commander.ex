defmodule IncidentCommander.Commander do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(_opts) do
    send(self(), :subscribe)
    {:ok, %{active_incidents: [], response_log: []}}
  end

  @impl true
  def handle_info(:subscribe, state) do
    IncidentCommander.AlertBus.subscribe(:critical_alerts)
    {:noreply, state}
  end

  def handle_info({:incident_alert, :critical_alerts, alert}, state) do
    action = %{id: "repair-#{alert.system}", system: alert.system, action: "dispatch repair crew"}
    :ok = IncidentCommander.MaintenanceQueue.enqueue(action)

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
