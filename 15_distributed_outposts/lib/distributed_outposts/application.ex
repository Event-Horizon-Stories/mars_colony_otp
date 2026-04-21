defmodule DistributedOutposts.Application do
  @moduledoc """
  Boots the full colony plus one local beacon that can be discovered from other nodes.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: DistributedOutposts.Registry},
      {Registry, keys: :duplicate, name: DistributedOutposts.AlertRegistry},
      {DistributedOutposts.HabitatFleet, []},
      {DistributedOutposts.OperationsSupervisor, []},
      {DistributedOutposts.CommunicationsSupervisor, []},
      {DistributedOutposts.RoverSupervisor, []},
      {Task.Supervisor, name: DistributedOutposts.TaskSupervisor},
      {DistributedOutposts.MaintenanceQueue, max_queue: 2},
      {DistributedOutposts.Commander, []},
      {DistributedOutposts.OutpostBeacon, []}
    ]

    opts = [strategy: :one_for_one, name: DistributedOutposts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
