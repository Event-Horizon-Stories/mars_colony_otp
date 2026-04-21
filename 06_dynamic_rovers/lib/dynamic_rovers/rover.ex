defmodule DynamicRovers.Rover do
  @moduledoc """
  A rover process created for one runtime mission.

  Rovers are intentionally smaller than habitats. The point is to show a worker
  that can appear, do a job, and disappear cleanly.
  """

  use GenServer

  def start_link(opts) do
    id = Keyword.fetch!(opts, :id)

    # Register by rover ID so the public API can find it later without exposing PIDs.
    name = {:via, Registry, {DynamicRovers.Registry, id}}
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def status(server), do: GenServer.call(server, :status)
  def assign_mission(server, mission), do: GenServer.call(server, {:assign_mission, mission})

  @impl true
  def init(opts) do
    {:ok,
     %{
       id: Keyword.fetch!(opts, :id),
       # Battery is part of the state so beginners can see the rover owns real data.
       battery: Keyword.get(opts, :battery, 100),
       mission: nil,
       status: :idle
     }}
  end

  @impl true
  def handle_call(:status, _from, state), do: {:reply, state, state}

  def handle_call({:assign_mission, mission}, _from, state) do
    # Assigning a mission also changes the rover's status so the transition is visible.
    next_state = %{state | mission: mission, status: :deployed}
    {:reply, {:ok, next_state}, next_state}
  end
end
