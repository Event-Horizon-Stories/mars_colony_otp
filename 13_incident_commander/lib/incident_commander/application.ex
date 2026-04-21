defmodule IncidentCommander.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: IncidentCommander.Registry},
      {Registry, keys: :duplicate, name: IncidentCommander.AlertRegistry},
      {IncidentCommander.HabitatFleet, []},
      {IncidentCommander.OperationsSupervisor, []},
      {IncidentCommander.CommunicationsSupervisor, []},
      {IncidentCommander.RoverSupervisor, []},
      {Task.Supervisor, name: IncidentCommander.TaskSupervisor},
      {IncidentCommander.MaintenanceQueue, max_queue: 2},
      {IncidentCommander.Commander, []}
    ]

    opts = [strategy: :one_for_one, name: IncidentCommander.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
