defmodule IncidentCommander.AlertBus do
  @moduledoc """
  A tiny pubsub-style surface for incident alerts.

  this module stays small on purpose. The lesson is not in the bus itself. The
  lesson is that the commander can subscribe to one topic and react to alerts
  without every alert publisher knowing about the commander directly.
  """

  def subscribe(topic) do
    Registry.register(IncidentCommander.AlertRegistry, topic, [])
  end

  def publish(topic, payload) do
    Registry.dispatch(IncidentCommander.AlertRegistry, topic, fn entries ->
      for {pid, _meta} <- entries do
        # Translate the generic topic broadcast into the message shape the commander expects.
        send(pid, {:incident_alert, topic, payload})
      end
    end)
  end
end
