defmodule HabitatServer.Habitat do
  @moduledoc """
  A single habitat implemented as a `GenServer`.

  The main point of this module is not "how to write callbacks." The point is to
  show what changes when lesson 1's plain data structure starts *owning* its
  state inside a long-lived process.
  """

  use GenServer

  def start_link(opts) do
    # `name:` is optional in `GenServer.start_link/3`, but this lesson uses it so
    # beginners can talk to the process through a stable name instead of a PID.
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name))
  end

  # `call/2` is synchronous, so the caller waits for the latest habitat state.
  def get_status(server), do: GenServer.call(server, :get_status)

  def consume_resource(server, resource, amount),
    do: GenServer.call(server, {:consume_resource, resource, amount})

  # `cast/2` is asynchronous, which fits "schedule this work and move on."
  def schedule_maintenance(server, system),
    do: GenServer.cast(server, {:schedule_maintenance, system})

  @impl true
  def init(opts) do
    {:ok,
     %{
       name: Keyword.fetch!(opts, :habitat_name),
       oxygen: Keyword.get(opts, :oxygen, 100),
       water: Keyword.get(opts, :water, 100),
       power: Keyword.get(opts, :power, 100),
       maintenance_backlog: [],
       status_log: []
     }}
  end

  # Return the full state so the chapter keeps the runtime visible while learning.
  @impl true
  def handle_call(:get_status, _from, state), do: {:reply, state, state}

  def handle_call({:consume_resource, resource, amount}, _from, state)
      when resource in [:oxygen, :water, :power] and is_integer(amount) and amount > 0 do
    # The process now owns the state transition that lesson 1 did in pure code.
    updated = max(Map.fetch!(state, resource) - amount, 0)

    next_state =
      state |> Map.put(resource, updated) |> append_status("#{resource} adjusted to #{updated}")

    # The reply and the next server state are both `next_state`.
    {:reply, next_state, next_state}
  end

  @impl true
  def handle_cast({:schedule_maintenance, system}, state) do
    next_state =
      state
      |> Map.update!(:maintenance_backlog, &(&1 ++ [system]))
      |> append_status("maintenance scheduled for #{system}")

    # Cast handlers never reply to the caller. They only return the next state.
    {:noreply, next_state}
  end

  defp append_status(state, entry) do
    Map.update!(state, :status_log, &(&1 ++ [entry]))
  end
end
