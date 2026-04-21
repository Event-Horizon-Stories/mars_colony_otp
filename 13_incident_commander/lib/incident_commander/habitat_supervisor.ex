defmodule IncidentCommander.HabitatSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(id) do
    Supervisor.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    children = [
      Supervisor.child_spec(
        {IncidentCommander.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
        id: {IncidentCommander.LifeSupportUnit, id, :atmosphere}
      ),
      Supervisor.child_spec(
        {IncidentCommander.LifeSupportUnit, habitat_id: id, subsystem: :water},
        id: {IncidentCommander.LifeSupportUnit, id, :water}
      ),
      Supervisor.child_spec(
        {IncidentCommander.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
        id: {IncidentCommander.LifeSupportUnit, id, :thermal}
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
