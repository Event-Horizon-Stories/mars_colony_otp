defmodule BackpressureAndQueues.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {BackpressureAndQueues.MaintenanceQueue, max_queue: 2}
    ]

    opts = [strategy: :one_for_one, name: BackpressureAndQueues.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
