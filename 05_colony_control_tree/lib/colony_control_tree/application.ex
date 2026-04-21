defmodule ColonyControlTree.Application do
  @moduledoc """
  Boots the colony's top-level supervision tree for lesson 5.

  Once the code reaches this chapter, startup order and supervision boundaries
  start mattering more than any single worker. This module is the bird's-eye
  view of the colony.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ColonyControlTree.Registry},
      # Keep the habitat subtree from the previous lesson.
      {ColonyControlTree.HabitatFleet, []},
      # Add a separate operations branch so domain ownership is visible at boot.
      {ColonyControlTree.OperationsSupervisor, []},
      {ColonyControlTree.CommunicationsSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: ColonyControlTree.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
