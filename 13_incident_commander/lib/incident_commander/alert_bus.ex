defmodule IncidentCommander.AlertBus do
  @moduledoc false

  def subscribe(topic) do
    Registry.register(IncidentCommander.Registry, topic, [])
  end

  def publish(topic, payload) do
    Registry.dispatch(IncidentCommander.Registry, topic, fn entries ->
      for {pid, _meta} <- entries do
        send(pid, {:incident_alert, topic, payload})
      end
    end)
  end
end
