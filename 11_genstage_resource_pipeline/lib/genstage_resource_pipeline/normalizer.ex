defmodule GenstageResourcePipeline.Normalizer do
  @moduledoc false

  use GenStage

  def start_link(opts) do
    upstream = Keyword.fetch!(opts, :upstream)
    GenStage.start_link(__MODULE__, upstream)
  end

  @impl true
  def init(upstream) do
    {:producer_consumer, :ok, subscribe_to: [upstream]}
  end

  @impl true
  def handle_events(events, _from, state) do
    normalized =
      Enum.map(events, fn event ->
        cond do
          Map.has_key?(event, :temperature_f) ->
            Map.put(event, :temperature_c, Float.round((event.temperature_f - 32) * 5 / 9, 1))

          true ->
            event
        end
      end)

    {:noreply, normalized, state}
  end
end
