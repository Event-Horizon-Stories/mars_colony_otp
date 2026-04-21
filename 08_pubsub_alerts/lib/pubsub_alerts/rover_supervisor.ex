defmodule PubsubAlerts.RoverSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def launch_rover(id, opts) do
    child_spec =
      Supervisor.child_spec(
        {PubsubAlerts.Rover, Keyword.merge(opts, id: id)},
        id: {:rover, id},
        restart: :temporary
      )

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
