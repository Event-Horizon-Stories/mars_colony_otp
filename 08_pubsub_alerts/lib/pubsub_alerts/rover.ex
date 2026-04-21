defmodule PubsubAlerts.Rover do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)
    name = {:via, Registry, {PubsubAlerts.Registry, id}}
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def status(server), do: GenServer.call(server, :status)
  def assign_mission(server, mission), do: GenServer.call(server, {:assign_mission, mission})

  @impl true
  def init(opts) do
    {:ok,
     %{
       id: Keyword.fetch!(opts, :id),
       battery: Keyword.get(opts, :battery, 100),
       mission: nil,
       status: :idle
     }}
  end

  @impl true
  def handle_call(:status, _from, state), do: {:reply, state, state}

  def handle_call({:assign_mission, mission}, _from, state) do
    next_state = %{state | mission: mission, status: :deployed}
    {:reply, {:ok, next_state}, next_state}
  end
end
