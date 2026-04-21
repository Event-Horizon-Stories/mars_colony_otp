defmodule DynamicRovers.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: DynamicRovers.Registry},
      {DynamicRovers.HabitatFleet, []},
      {DynamicRovers.OperationsSupervisor, []},
      {DynamicRovers.CommunicationsSupervisor, []},
      {DynamicRovers.RoverSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: DynamicRovers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
