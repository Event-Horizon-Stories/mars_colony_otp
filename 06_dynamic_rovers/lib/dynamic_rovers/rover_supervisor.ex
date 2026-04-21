defmodule DynamicRovers.RoverSupervisor do
  @moduledoc """
  Starts rovers only when a mission actually needs one.

  This is the chapter's first clear example of a worker whose lifetime is driven
  by runtime demand instead of application startup.
  """

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def launch_rover(id, opts) do
    child_spec =
      Supervisor.child_spec(
        {DynamicRovers.Rover, Keyword.merge(opts, id: id)},
        id: {:rover, id},
        # A retired rover should not come back automatically.
        restart: :temporary
      )

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @impl true
  def init(_opts), do: DynamicSupervisor.init(strategy: :one_for_one)
end
