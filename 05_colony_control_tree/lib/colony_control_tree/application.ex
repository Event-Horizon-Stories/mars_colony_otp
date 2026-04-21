defmodule ColonyControlTree.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ColonyControlTree.Registry},
      {ColonyControlTree.HabitatFleet, []},
      {ColonyControlTree.OperationsSupervisor, []},
      {ColonyControlTree.CommunicationsSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: ColonyControlTree.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
