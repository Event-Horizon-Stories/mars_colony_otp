defmodule TasksAndTimeouts.HabitatSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(id) do
    Supervisor.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    children = [
      Supervisor.child_spec(
        {TasksAndTimeouts.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
        id: {TasksAndTimeouts.LifeSupportUnit, id, :atmosphere}
      ),
      Supervisor.child_spec(
        {TasksAndTimeouts.LifeSupportUnit, habitat_id: id, subsystem: :water},
        id: {TasksAndTimeouts.LifeSupportUnit, id, :water}
      ),
      Supervisor.child_spec(
        {TasksAndTimeouts.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
        id: {TasksAndTimeouts.LifeSupportUnit, id, :thermal}
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
