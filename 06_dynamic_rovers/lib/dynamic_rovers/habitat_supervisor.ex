defmodule DynamicRovers.HabitatSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(id) do
    Supervisor.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    children = [
      Supervisor.child_spec(
        {DynamicRovers.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
        id: {DynamicRovers.LifeSupportUnit, id, :atmosphere}
      ),
      Supervisor.child_spec(
        {DynamicRovers.LifeSupportUnit, habitat_id: id, subsystem: :water},
        id: {DynamicRovers.LifeSupportUnit, id, :water}
      ),
      Supervisor.child_spec(
        {DynamicRovers.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
        id: {DynamicRovers.LifeSupportUnit, id, :thermal}
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
