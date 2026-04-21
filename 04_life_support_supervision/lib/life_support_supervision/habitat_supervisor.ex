defmodule LifeSupportSupervision.HabitatSupervisor do
  @moduledoc """
  Supervises the subsystems that keep one habitat alive.

  The important lesson is the relationship between the children, not the child
  code itself. Atmosphere, water, and thermal are siblings so they can fail
  independently under `:one_for_one`.
  """

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

    # Only restart the subsystem that crashed.
    Supervisor.init(children, strategy: :one_for_one)
  end
end
