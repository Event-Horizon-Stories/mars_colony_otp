defmodule GenstageResourcePipeline do
  @moduledoc """
  Public API for the GenStage telemetry lesson.
  """

  def start_pipeline(opts) do
    producer_name = Keyword.get(opts, :producer_name, GenstageResourcePipeline.SensorProducer)
    notify = Keyword.fetch!(opts, :notify)

    {:ok, producer} = GenstageResourcePipeline.SensorProducer.start_link(name: producer_name)
    {:ok, normalizer} = GenstageResourcePipeline.Normalizer.start_link(upstream: producer)

    {:ok, sink} =
      GenstageResourcePipeline.AnomalySink.start_link(upstream: normalizer, notify: notify)

    {:ok, %{producer: producer, normalizer: normalizer, sink: sink}}
  end

  def publish_sensor_packet(packet, producer \\ GenstageResourcePipeline.SensorProducer) do
    GenstageResourcePipeline.SensorProducer.publish(producer, packet)
  end
end
