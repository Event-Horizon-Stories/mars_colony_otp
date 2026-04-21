defmodule PubsubAlerts.HabitatSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(id) do
    Supervisor.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    children = [
      Supervisor.child_spec(
        {PubsubAlerts.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
        id: {PubsubAlerts.LifeSupportUnit, id, :atmosphere}
      ),
      Supervisor.child_spec(
        {PubsubAlerts.LifeSupportUnit, habitat_id: id, subsystem: :water},
        id: {PubsubAlerts.LifeSupportUnit, id, :water}
      ),
      Supervisor.child_spec(
        {PubsubAlerts.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
        id: {PubsubAlerts.LifeSupportUnit, id, :thermal}
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
