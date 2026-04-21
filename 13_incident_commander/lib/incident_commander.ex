defmodule IncidentCommander do
  @moduledoc """
  Public API for the incident response lesson.
  """

  def report_alert(alert) do
    IncidentCommander.AlertBus.publish(:critical_alerts, alert)
  end

  def incident_snapshot do
    IncidentCommander.Commander.snapshot()
  end

  def queue_snapshot do
    IncidentCommander.MaintenanceQueue.snapshot()
  end
end
