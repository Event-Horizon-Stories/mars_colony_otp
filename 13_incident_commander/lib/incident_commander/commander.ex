defmodule IncidentCommander.Commander do
  @moduledoc """
  Owns the live state of the colony's incident response.

  Beginner note:
  this is an orchestration process. Its job is not just to forward a message. It
  keeps a durable view of "what incidents are active?" and "what response did we
  take?" while also triggering repair work.
  """

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def snapshot, do: GenServer.call(__MODULE__, :snapshot)

  @impl true
  def init(_opts) do
    # Subscribe after init so startup stays simple and the mailbox remains explicit.
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
      | # Keep the raw alert so operators can inspect which incidents are still active.
        active_incidents: state.active_incidents ++ [alert],
        # Keep a separate human-readable response trail for the tutorial.
        response_log: state.response_log ++ ["reroute load and dispatch #{alert.system} repair"]
    }

    {:noreply, next_state}
  end

  @impl true
  def handle_call(:snapshot, _from, state), do: {:reply, state, state}
end
