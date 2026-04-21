defmodule NamedHabitats.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: NamedHabitats.Registry},
      {NamedHabitats.HabitatSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: NamedHabitats.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
