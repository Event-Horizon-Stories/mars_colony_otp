defmodule DistributedOutposts.OperationsSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      Supervisor.child_spec({DistributedOutposts.DomainService, service: :mission_control},
        id: :mission_control_service
      ),
      Supervisor.child_spec({DistributedOutposts.DomainService, service: :storage},
        id: :storage_service
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule DistributedOutposts.CommunicationsSupervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {DistributedOutposts.DomainService, service: :comms_relay}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
