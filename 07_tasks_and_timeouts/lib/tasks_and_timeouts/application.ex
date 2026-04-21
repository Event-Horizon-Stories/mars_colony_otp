defmodule TasksAndTimeouts.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: TasksAndTimeouts.Registry},
      {TasksAndTimeouts.HabitatFleet, []},
      {TasksAndTimeouts.OperationsSupervisor, []},
      {TasksAndTimeouts.CommunicationsSupervisor, []},
      {TasksAndTimeouts.RoverSupervisor, []},
      {Task.Supervisor, name: TasksAndTimeouts.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: TasksAndTimeouts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
