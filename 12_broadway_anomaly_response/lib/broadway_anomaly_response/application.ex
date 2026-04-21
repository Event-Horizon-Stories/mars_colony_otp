defmodule BroadwayAnomalyResponse.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: BroadwayAnomalyResponse.Registry},
      {Registry, keys: :duplicate, name: BroadwayAnomalyResponse.AlertRegistry},
      {BroadwayAnomalyResponse.HabitatFleet, []},
      {BroadwayAnomalyResponse.OperationsSupervisor, []},
      {BroadwayAnomalyResponse.CommunicationsSupervisor, []},
      {BroadwayAnomalyResponse.RoverSupervisor, []},
      {Task.Supervisor, name: BroadwayAnomalyResponse.TaskSupervisor},
      {BroadwayAnomalyResponse.MaintenanceQueue, max_queue: 2}
    ]

    opts = [strategy: :one_for_one, name: BroadwayAnomalyResponse.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
