defmodule LifeSupportSupervision.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: LifeSupportSupervision.Registry},
      {LifeSupportSupervision.HabitatFleet, []}
    ]

    opts = [strategy: :one_for_one, name: LifeSupportSupervision.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
