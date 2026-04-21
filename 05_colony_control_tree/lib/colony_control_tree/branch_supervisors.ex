defmodule ColonyControlTree.OperationsSupervisor do
  @moduledoc """
  Owns the operations branch of the colony tree.

  Splitting the root into smaller supervisors makes the runtime map look more
  like the real system. Operations and communications are separate branches
  because they are separate domains.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Mission control and storage belong to the same domain branch here.
      Supervisor.child_spec({ColonyControlTree.DomainService, service: :mission_control},
        id: :mission_control_service
      ),
      Supervisor.child_spec({ColonyControlTree.DomainService, service: :storage},
        id: :storage_service
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule ColonyControlTree.CommunicationsSupervisor do
  @moduledoc """
  Owns the communications branch of the colony tree.
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {ColonyControlTree.DomainService, service: :comms_relay}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
