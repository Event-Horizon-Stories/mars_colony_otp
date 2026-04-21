defmodule LifeSupportSupervision.HabitatSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(id) do
    Supervisor.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    children = [
      Supervisor.child_spec(
        {LifeSupportSupervision.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
        id: {LifeSupportSupervision.LifeSupportUnit, id, :atmosphere}
      ),
      Supervisor.child_spec(
        {LifeSupportSupervision.LifeSupportUnit, habitat_id: id, subsystem: :water},
        id: {LifeSupportSupervision.LifeSupportUnit, id, :water}
      ),
      Supervisor.child_spec(
        {LifeSupportSupervision.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
        id: {LifeSupportSupervision.LifeSupportUnit, id, :thermal}
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
