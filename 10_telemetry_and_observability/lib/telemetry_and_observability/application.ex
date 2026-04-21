defmodule TelemetryAndObservability.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: TelemetryAndObservability.Registry},
      {Registry, keys: :duplicate, name: TelemetryAndObservability.AlertRegistry},
      {TelemetryAndObservability.HabitatFleet, []},
      {TelemetryAndObservability.OperationsSupervisor, []},
      {TelemetryAndObservability.CommunicationsSupervisor, []},
      {TelemetryAndObservability.RoverSupervisor, []},
      {Task.Supervisor, name: TelemetryAndObservability.TaskSupervisor},
      {TelemetryAndObservability.MaintenanceQueue, max_queue: 2}
    ]

    opts = [strategy: :one_for_one, name: TelemetryAndObservability.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
