defmodule BackpressureAndQueues.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: BackpressureAndQueues.Registry},
      {Registry, keys: :duplicate, name: BackpressureAndQueues.AlertRegistry},
      {BackpressureAndQueues.HabitatFleet, []},
      {BackpressureAndQueues.OperationsSupervisor, []},
      {BackpressureAndQueues.CommunicationsSupervisor, []},
      {BackpressureAndQueues.RoverSupervisor, []},
      {Task.Supervisor, name: BackpressureAndQueues.TaskSupervisor},
      {BackpressureAndQueues.MaintenanceQueue, max_queue: 2}
    ]

    opts = [strategy: :one_for_one, name: BackpressureAndQueues.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
