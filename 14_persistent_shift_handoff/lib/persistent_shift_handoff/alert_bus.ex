defmodule PersistentShiftHandoff.AlertBus do
  @moduledoc false

  def subscribe(topic) do
    Registry.register(PersistentShiftHandoff.AlertRegistry, topic, [])
  end

  def publish(topic, payload) do
    Registry.dispatch(PersistentShiftHandoff.AlertRegistry, topic, fn entries ->
      for {pid, _meta} <- entries do
        send(pid, {:incident_alert, topic, payload})
      end
    end)
  end
end
