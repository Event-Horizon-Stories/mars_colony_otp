defmodule PersistentShiftHandoff.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: PersistentShiftHandoff.Registry},
      {Registry, keys: :duplicate, name: PersistentShiftHandoff.AlertRegistry},
      {PersistentShiftHandoff.HabitatFleet, []},
      {PersistentShiftHandoff.OperationsSupervisor, []},
      {PersistentShiftHandoff.CommunicationsSupervisor, []},
      {PersistentShiftHandoff.RoverSupervisor, []},
      {Task.Supervisor, name: PersistentShiftHandoff.TaskSupervisor},
      {PersistentShiftHandoff.MaintenanceQueue, max_queue: 2},
      {PersistentShiftHandoff.Commander, []}
    ]

    opts = [strategy: :one_for_one, name: PersistentShiftHandoff.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
