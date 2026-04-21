defmodule PubsubAlerts do
  @moduledoc """
  Local alert fan-out built on `Registry`.
  """

  def subscribe(topic) when is_atom(topic) do
    Registry.register(PubsubAlerts.Registry, topic, [])
  end

  def publish(topic, payload) when is_atom(topic) do
    Registry.dispatch(PubsubAlerts.Registry, topic, fn entries ->
      for {pid, _meta} <- entries do
        send(pid, {:colony_alert, topic, payload})
      end
    end)
  end
end
