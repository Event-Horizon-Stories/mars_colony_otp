defmodule TelemetryAndObservability do
  @moduledoc """
  Queue API instrumented with `:telemetry`.
  """

  def enqueue_request(request), do: TelemetryAndObservability.MaintenanceQueue.enqueue(request)
  def dispatch_next, do: TelemetryAndObservability.MaintenanceQueue.dispatch_next()
  def snapshot, do: TelemetryAndObservability.MaintenanceQueue.snapshot()
end
