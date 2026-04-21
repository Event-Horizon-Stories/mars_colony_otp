defmodule GenstageResourcePipeline.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: GenstageResourcePipeline.Registry},
      {Registry, keys: :duplicate, name: GenstageResourcePipeline.AlertRegistry},
      {GenstageResourcePipeline.HabitatFleet, []},
      {GenstageResourcePipeline.OperationsSupervisor, []},
      {GenstageResourcePipeline.CommunicationsSupervisor, []},
      {GenstageResourcePipeline.RoverSupervisor, []},
      {Task.Supervisor, name: GenstageResourcePipeline.TaskSupervisor},
      {GenstageResourcePipeline.MaintenanceQueue, max_queue: 2}
    ]

    opts = [strategy: :one_for_one, name: GenstageResourcePipeline.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
