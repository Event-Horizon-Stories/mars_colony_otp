defmodule IncidentCommander.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :duplicate, name: IncidentCommander.Registry},
      {IncidentCommander.MaintenanceQueue, []},
      {IncidentCommander.Commander, []}
    ]

    opts = [strategy: :one_for_one, name: IncidentCommander.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
