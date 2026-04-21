defmodule PubsubAlerts.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :duplicate, name: PubsubAlerts.Registry}
    ]

    opts = [strategy: :one_for_one, name: PubsubAlerts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
