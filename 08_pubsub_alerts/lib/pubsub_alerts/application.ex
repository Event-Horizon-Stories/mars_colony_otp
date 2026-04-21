defmodule PubsubAlerts.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: PubsubAlerts.Registry},
      {Registry, keys: :duplicate, name: PubsubAlerts.AlertRegistry},
      {PubsubAlerts.HabitatFleet, []},
      {PubsubAlerts.OperationsSupervisor, []},
      {PubsubAlerts.CommunicationsSupervisor, []},
      {PubsubAlerts.RoverSupervisor, []},
      {Task.Supervisor, name: PubsubAlerts.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: PubsubAlerts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
