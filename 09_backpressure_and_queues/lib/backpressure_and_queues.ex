defmodule BackpressureAndQueues do
  @moduledoc """
  Queue API for maintenance intake.
  """

  def enqueue_request(request), do: BackpressureAndQueues.MaintenanceQueue.enqueue(request)
  def dispatch_next, do: BackpressureAndQueues.MaintenanceQueue.dispatch_next()
  def ack_request(id), do: BackpressureAndQueues.MaintenanceQueue.ack(id)
  def snapshot, do: BackpressureAndQueues.MaintenanceQueue.snapshot()
end
