defmodule BroadwayAnomalyResponse.AnomalySink do
  @moduledoc false

  use GenStage

  def start_link(opts) do
    upstream = Keyword.fetch!(opts, :upstream)
    notify = Keyword.fetch!(opts, :notify)
    GenStage.start_link(__MODULE__, %{upstream: upstream, notify: notify})
  end

  @impl true
  def init(%{upstream: upstream} = state) do
    {:consumer, state, subscribe_to: [upstream]}
  end

  @impl true
  def handle_events(events, _from, state) do
    Enum.each(events, fn event ->
      if event[:temperature_c] && event.temperature_c >= 65.0 do
        send(
          state.notify,
          {:anomaly_detected, %{sensor_id: event.sensor_id, temperature_c: event.temperature_c}}
        )
      end
    end)

    {:noreply, [], state}
  end
end
