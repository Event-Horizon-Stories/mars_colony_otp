defmodule DistributedOutposts.HabitatSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(id) do
    Supervisor.start_link(__MODULE__, id)
  end

  @impl true
  def init(id) do
    children = [
      Supervisor.child_spec(
        {DistributedOutposts.LifeSupportUnit, habitat_id: id, subsystem: :atmosphere},
        id: {DistributedOutposts.LifeSupportUnit, id, :atmosphere}
      ),
      Supervisor.child_spec(
        {DistributedOutposts.LifeSupportUnit, habitat_id: id, subsystem: :water},
        id: {DistributedOutposts.LifeSupportUnit, id, :water}
      ),
      Supervisor.child_spec(
        {DistributedOutposts.LifeSupportUnit, habitat_id: id, subsystem: :thermal},
        id: {DistributedOutposts.LifeSupportUnit, id, :thermal}
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
